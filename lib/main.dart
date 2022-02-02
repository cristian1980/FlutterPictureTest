
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'raw_picture_render.dart';

void main() {
  // debugRepaintRainbowEnabled = true;

  const double width = 1000;
  const double height = 1000;
  final PictureRecorder recorder = PictureRecorder();
  final Canvas canvas = Canvas(recorder, const Rect.fromLTWH(0,0,width,height));
  canvas.save();
  final bgPaint = Paint()..color = Colors.yellow;
  canvas.drawPaint(bgPaint);

    Paint paint1 = Paint();
  paint1
    ..color = Colors.red
    ..style = PaintingStyle.fill
    ..strokeWidth = 0;

  const double heartCount = 40;

  double heartWidth = width/heartCount;
  double heartHeight = height/heartCount;
  String svg = "<svg height=\"$height\" viewBox=\"0 0 $width $height\" width=\"$width\" xmlns=\"http://www.w3.org/2000/svg\">\n";
  for (int x = 0; x < heartCount; x++) {
    for (int y = 0; y < heartCount; y++) {
      String svgPath = "<path d=\"";
      Path path = Path();
      double offsetX = heartWidth * x;
      double offsetY = heartHeight * y;

      double tmpX = 0.5 * heartWidth + offsetX;
      double tmpY = heartHeight * 0.35 + offsetY;
      path.moveTo(tmpX, tmpY);
      svgPath+= "M" + tmpX.toStringAsFixed(2) + " " + tmpY.toStringAsFixed(2);

      double tmpX1 = 0.2 * heartWidth + offsetX;
      double tmpY1 = heartHeight * 0.1 + offsetY;
      double tmpX2 = -0.25 * heartWidth + offsetX;
      double tmpY2 = heartHeight * 0.6 + offsetY;
      double tmpX3 = 0.5 * heartWidth + offsetX;
      double tmpY3 = heartHeight + offsetY;
      path.cubicTo(tmpX1, tmpY1, tmpX2, tmpY2, tmpX3, tmpY3);
      svgPath+= "C" + tmpX1.toStringAsFixed(2) +" " + tmpY1.toStringAsFixed(2)
          + " " + tmpX2.toStringAsFixed(2) +" " + tmpY2.toStringAsFixed(2)
          + " " + tmpX3.toStringAsFixed(2) +" " + tmpY3.toStringAsFixed(2);

      path.moveTo(tmpX, tmpY);
      svgPath+= "M" + tmpX.toStringAsFixed(2) + " " + tmpY.toStringAsFixed(2);

      tmpX1 = 0.8 * heartWidth + offsetX;
      tmpX2 = 1.25 * heartWidth + offsetX;
      path.cubicTo(tmpX1, tmpY1, tmpX2, tmpY2, tmpX3, tmpY3);
      svgPath+= "C" + tmpX1.toStringAsFixed(2) +" " + tmpY1.toStringAsFixed(2)
          + " " + tmpX2.toStringAsFixed(2) +" " + tmpY2.toStringAsFixed(2)
          + " " + tmpX3.toStringAsFixed(2) +" " + tmpY3.toStringAsFixed(2);
      svgPath+="\" fill=\"#ff0000\"/>\n";
      svg += svgPath;
      canvas.drawPath(path, paint1);
    }
  }
  svg += "</svg>";
  canvas.restore();
  Picture picture = recorder.endRecording();
  int? bytes = picture.approximateBytesUsed;
  if (kDebugMode) {
    print("image size in bytes: " + bytes.toString());
    //print(svg);
  }
  runApp(MyApp(
    picture: picture,
    width: width,
    height: height,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.picture,required this.width,required this.height, Key? key}):super(key: key);
  final Picture picture;
  final double width ;
  final double height ;
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            // color: Colors.cyan,

            child:  InteractiveViewer(
              minScale: 0.1,
              maxScale: 20,
              child: SizedBox(
                width: width,
                height: height,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  child: RawPicture(
                    picture: picture,
                    pictureSize: Size(width, height),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
