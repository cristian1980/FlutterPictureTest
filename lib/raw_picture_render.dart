import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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