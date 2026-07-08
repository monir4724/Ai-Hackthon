// One-off: square-crop logo for launcher icons (shield centered, brand background).
// Run: dart run tool/prepare_icon.dart
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final source = File('assets/app_icon_source.png');
  final decoded = img.decodePng(source.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Failed to decode source icon');
    exit(1);
  }

  final side = decoded.width < decoded.height ? decoded.width : decoded.height;
  final left = (decoded.width - side) ~/ 2;
  final top = (decoded.height - side) ~/ 2;
  final square = img.copyCrop(decoded, x: left, y: top, width: side, height: side);
  final sized = img.copyResize(square, width: 1024, height: 1024);

  File('assets/app_icon.png').writeAsBytesSync(img.encodePng(sized));

  // Foreground for adaptive icon: upper 70% (shield + wordmark readable at scale)
  final fgHeight = (side * 0.92).round();
  final fg = img.copyCrop(decoded, x: left, y: top, width: side, height: fgHeight);
  final fgSquare = img.Image(width: 1024, height: 1024);
  img.fill(fgSquare, color: img.ColorRgba8(0, 0, 0, 0));
  final fgResized = img.copyResize(fg, width: 900, height: 900);
  img.compositeImage(
    fgSquare,
    fgResized,
    dstX: (1024 - fgResized.width) ~/ 2,
    dstY: (1024 - fgResized.height) ~/ 2,
  );
  File('assets/app_icon_foreground.png').writeAsBytesSync(img.encodePng(fgSquare));

  stdout.writeln('Prepared assets/app_icon.png and assets/app_icon_foreground.png');
}
