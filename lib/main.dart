
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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


///////////////////////



class RawPicture extends LeafRenderObjectWidget {
  const RawPicture({required this.picture, Key? key, this.pictureSize = const Size(1000, 1000)}) : super(key: key);

  final Size pictureSize;
  final Picture picture;

  @override
  RenderRawPicture createRenderObject(BuildContext context) {
    return RenderRawPicture(
      pictureSize: pictureSize,
      picture: picture,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderRawPicture renderObject) {
    renderObject
      ..pictureSize = pictureSize
      ..picture = picture;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('pictureWidth', pictureSize.width));
    properties.add(DoubleProperty('pictureHeight', pictureSize.height));
  }
}

class RenderRawPicture extends RenderBox {
  RenderRawPicture({
    required Size pictureSize,
    required Picture picture
  })  :  _pictureSize = pictureSize {
    this.picture  = picture;
  }

  final LayerHandle<PictureLayer> _pictureHandle = LayerHandle<PictureLayer>();
  final LayerHandle<ClipRectLayer> _clipHandle = LayerHandle<ClipRectLayer>();

  Picture? get picture => _picture;
  Picture? _picture;
  set picture(Picture? value) {
    if (_picture == value) return;
    _picture = value;
    _pictureHandle.layer = _NonOwningPictureLayer(Rect.fromLTWH(0, 0, pictureSize.width, pictureSize.height))
      ..picture = picture
      ..isComplexHint = true;

    markNeedsLayout();
  }

  Size get pictureSize => _pictureSize;
  Size _pictureSize;
  set pictureSize(Size value) {
    if (_pictureSize == value) return;
    _pictureSize = value;
    markNeedsLayout();
  }


  @override
  double computeMinIntrinsicWidth(double height) => pictureSize.width;

  @override
  double computeMaxIntrinsicWidth(double height) => pictureSize.width;

  @override
  double computeMinIntrinsicHeight(double width) => pictureSize.height;

  @override
  double computeMaxIntrinsicHeight(double width) => pictureSize.height;


  @override
  bool hitTestSelf(Offset position) => false;


  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    // final desiredWidth = constraints.maxWidth;
    // final desiredHeight = pictureSize;
    final desiredSize = pictureSize;
    return constraints.constrain(desiredSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if(_pictureHandle.layer!=null && _picture!=null) {
      final Rect viewportRect = Offset.zero & pictureSize;
      _clipHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        viewportRect,
            (PaintingContext context, Offset offset) {
          context.addLayer(_pictureHandle.layer!);
        },
        oldLayer: _clipHandle.layer,
      );
    }

  }

  @override
  bool get isRepaintBoundary => true;


}
class _NonOwningPictureLayer extends PictureLayer {
  _NonOwningPictureLayer(Rect canvasBounds) : super(canvasBounds);

  @override
  Picture? get picture => _picture;

  Picture? _picture;

  @override
  set picture(Picture? picture) {
    markNeedsAddToScene();
    // Do not dispose the picture, it's owned by the cache.
    _picture = picture;
  }
}
