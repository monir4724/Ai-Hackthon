import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:rokkhakoboch/core/media/ela_analyzer.dart';

void main() {
  test('ELA score is higher for locally edited JPEG region', () async {
    final original = img.Image(width: 200, height: 200);
    img.fill(original, color: img.ColorRgb8(120, 140, 160));

    final plainBytes = Uint8List.fromList(img.encodeJpg(original, quality: 95));
    final plain = await ElaAnalyzer.analyze(plainBytes);
    expect(plain, isNotNull);

    final edited = img.Image.from(original);
    for (var y = 60; y < 140; y++) {
      for (var x = 60; x < 140; x++) {
        edited.setPixelRgba(x, y, 250, 20, 20, 255);
      }
    }
    final editedBytes = Uint8List.fromList(img.encodeJpg(edited, quality: 95));
    final editedResult = await ElaAnalyzer.analyze(editedBytes);
    expect(editedResult, isNotNull);

    expect(editedResult!.signalScore, greaterThan(plain!.signalScore));
  });
}
