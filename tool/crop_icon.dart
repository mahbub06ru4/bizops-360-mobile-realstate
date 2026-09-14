// One-off: build the launcher-icon assets from the branding sheet
// (assets/logo.png). Produces:
//   assets/icon/app_icon.png            1024² — mark on white (legacy + iOS + web)
//   assets/icon/app_icon_foreground.png 1024² — mark on transparent, padded for
//                                       the Android adaptive-icon safe zone
//
//   dart run tool/crop_icon.dart [left] [top] [size]
//
// Defaults target the bottom-left lozenge of the 1254×1254 sheet.
import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final sheet = img.decodePng(File('assets/logo.png').readAsBytesSync());
  if (sheet == null) {
    stderr.writeln('could not decode assets/logo.png');
    exit(1);
  }

  final left = args.isNotEmpty ? int.parse(args[0]) : 150;
  final top = args.length > 1 ? int.parse(args[1]) : 772;
  final size = args.length > 2 ? int.parse(args[2]) : 320;

  final crop = img.copyCrop(sheet, x: left, y: top, width: size, height: size);

  // Full-bleed icon: the crop already sits on the sheet's white ground.
  final full = img.copyResize(crop, width: 1024, height: 1024);
  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(full));

  // Adaptive foreground: same mark at 64% on a transparent canvas.
  const canvas = 1024;
  const inner = 656; // 64%
  final scaled = img.copyResize(crop, width: inner, height: inner);
  final fg = img.Image(width: canvas, height: canvas, numChannels: 4);
  img.compositeImage(
    fg,
    scaled,
    dstX: (canvas - inner) ~/ 2,
    dstY: (canvas - inner) ~/ 2,
  );
  File(
    'assets/icon/app_icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(fg));

  stdout.writeln(
    'wrote assets/icon/app_icon.png + app_icon_foreground.png '
    '(crop ${size}px @ $left,$top)',
  );
}
