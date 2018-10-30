import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/rendering.dart';
import 'package:image/image.dart';

class Utils extends Object {
  static int baseId = 100;
  static String pageNameSeperatorToken = "_";

  static int generatePrimaryPageId() {
    return baseId++;
  }

  static Map parseUniquePageName(String pageName) {
    List components = pageName.split(pageNameSeperatorToken);
    if (components.length != 2) return null;
    return {"name": components[0], "id": components[1]};
  }

  static String generateUniquePageName(String pageName) {
    return (pageName ?? "") +
        pageNameSeperatorToken +
        generatePrimaryPageId().toString();
  }
  static Future<Image> getImage(RenderRepaintBoundary object) async {
    ui.Image capture = await object.toImage(pixelRatio: 2.0);
    ByteData data = await capture.toByteData();
    return new Image.fromBytes(capture.width, capture.height, data.buffer.asUint32List());
  }

  static Future<File> writeFile(Image outputImage,String fileName) async {
    final Directory directory = await getTemporaryDirectory();
    final File outputFile = new File(path.join(directory.path, fileName));
    List<int> output = encodePng(outputImage);
    return outputFile.writeAsBytes(output);
  }
}
