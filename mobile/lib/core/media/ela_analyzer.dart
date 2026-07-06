import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ElaResult {
  const ElaResult({
    required this.original,
    required this.heatmap,
    required this.verdictBn,
    required this.detailBn,
    required this.signalScore,
  });

  final img.Image original;
  final img.Image heatmap;
  final String verdictBn;
  final String detailBn;
  final double signalScore;
}

/// Experimental Error Level Analysis — heuristic only, not ML deepfake detection.
abstract final class ElaAnalyzer {
  static const _maxDimension = 1200;
  static const _jpegQuality = 90;

  static Future<ElaResult?> analyze(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final working = _downscale(decoded);
    final recompressed = img.decodeJpg(img.encodeJpg(working, quality: _jpegQuality));
    if (recompressed == null) return null;

    final aligned = img.copyResize(
      recompressed,
      width: working.width,
      height: working.height,
    );

    final heatmap = img.Image(width: working.width, height: working.height);
    final diffs = <int>[];

    for (var y = 0; y < working.height; y++) {
      for (var x = 0; x < working.width; x++) {
        final a = working.getPixel(x, y);
        final b = aligned.getPixel(x, y);
        final dr = (a.r - b.r).abs();
        final dg = (a.g - b.g).abs();
        final db = (a.b - b.b).abs();
        final diff = ((dr + dg + db) / 3).round().clamp(0, 255);
        diffs.add(diff);

        final amplified = (diff * 12).clamp(0, 255).toInt();
        heatmap.setPixelRgba(x, y, amplified, amplified ~/ 3, 0, 255);
      }
    }

    final score = _scoreSignal(diffs);
    final suspicious = score >= 18;

    return ElaResult(
      original: working,
      heatmap: heatmap,
      signalScore: score,
      verdictBn: suspicious
          ? 'কিছু এলাকায় অস্বাভাবিক সম্পাদনার চিহ্ন থাকতে পারে — সতর্ক থাকুন'
          : 'সম্পাদনার কোনো স্পষ্ট চিহ্ন পাওয়া যায়নি',
      detailBn: suspicious
          ? 'ELA সিগন্যাল তুলনামূলক বেশি — ছবিটি সম্ভবত পুনরায় সংকুচিত বা সম্পাদিত হয়েছে।'
          : 'ELA সিগন্যাল তুলনামূলক সমান — স্পষ্ট এডিটিং চিহ্ন দেখা যায়নি।',
    );
  }

  static img.Image _downscale(img.Image image) {
    final longest = image.width > image.height ? image.width : image.height;
    if (longest <= _maxDimension) return image;
    if (image.width >= image.height) {
      return img.copyResize(image, width: _maxDimension);
    }
    return img.copyResize(image, height: _maxDimension);
  }

  static double _scoreSignal(List<int> diffs) {
    if (diffs.isEmpty) return 0;
    final mean = diffs.reduce((a, b) => a + b) / diffs.length;
    var variance = 0.0;
    for (final d in diffs) {
      final delta = d - mean;
      variance += delta * delta;
    }
    variance /= diffs.length;
    final stdDev = math.sqrt(variance);
    final hotPixels = diffs.where((d) => d >= 12).length / diffs.length;
    return stdDev + (hotPixels * 40);
  }
}
