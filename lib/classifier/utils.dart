import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';


class PodocoHelpers{
  static createBitmapFromFile(File file) async{
    Uint8List imageBytes = await file.readAsBytes();
    ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}