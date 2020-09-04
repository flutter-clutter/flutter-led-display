import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_digital_text_display/text_to_picture_converter.dart';
import 'package:image/image.dart' as imagePackage;

class ToPixelsConverter {
  ToPixelsConverter.fromString({
    @required this.string,
    @required this.canvasSize,
    this.border = false,
  });

  ToPixelsConverter.fromCanvas({
    @required this.canvas,
    this.canvasSize
  });

  String string;
  Canvas canvas;
  bool border;
  final double canvasSize;

  Future<ToPixelsConversionResult> convert() async {
    final ui.Picture picture = TextToPictureConverter.convert(
      text: this.string, canvasSize: canvasSize, border: border
    );
    final ByteData imageBytes = await _pictureToBytes(picture);
    final List<List<Color>> pixels = _bytesToPixelArray(imageBytes);

    return ToPixelsConversionResult(
      imageBytes: imageBytes,
      pixels: pixels
    );
  }

  Future<ByteData> _pictureToBytes(ui.Picture picture) async {
    final ui.Image img = await picture.toImage(
      canvasSize.toInt(), canvasSize.toInt()
    );
    return await img.toByteData(format: ui.ImageByteFormat.png);
  }

  List<List<Color>> _bytesToPixelArray(ByteData imageBytes) {
    List<int> values = imageBytes.buffer.asUint8List();
    imagePackage.Image decodedImage = imagePackage.decodeImage(values);
    List<List<Color>> pixelArray = new List.generate(
      canvasSize.toInt(), (_) => new List(canvasSize.toInt())
    );

    for (int i = 0; i < canvasSize.toInt(); i++) {
      for (int j = 0; j < canvasSize.toInt(); j++) {
        int pixel = decodedImage.getPixelSafe(i, j);
        int hex = _convertColorSpace(pixel);
        pixelArray[i][j] = Color(hex);
      }
    }

    return pixelArray;
  }

  int _convertColorSpace(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }
}

class ToPixelsConversionResult {
  ToPixelsConversionResult({
    this.imageBytes,
    this.pixels
  });

  final ByteData imageBytes;
  final List<List<Color>> pixels;
}