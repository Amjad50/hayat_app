import 'package:flutter/material.dart';
import 'dart:math' as math;

class MyTrachShape extends SliderTrackShape with BaseSliderTrackShape {
  /// Create a slider track that draws two rectangles with rounded outer edges.
  const MyTrachShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required TextDirection textDirection,
    @required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider track height is less than or equal to 0, then it makes no
    // difference whether the track is painted or not, therefore the painting
    // can be a no-op.
    if (sliderTheme.trackHeight <= 0) {
      return;
    }

    // print(offset);

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation);
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // The arc rects create a semi-circle with radius equal to track height.
    final Rect leftTrackArcRect = Rect.fromLTWH(
      trackRect.left - trackRect.height / 2,
      trackRect.top,
      trackRect.height,
      trackRect.height,
    );

    final Rect rightTrackArcRect = Rect.fromLTWH(
      trackRect.right - trackRect.height / 2,
      trackRect.top,
      trackRect.height,
      trackRect.height,
    );

    final Rect leftTrackSegment = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    final Rect rightTrackSegment = Rect.fromLTRB(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    // draw
    if (!leftTrackArcRect.isEmpty)
      context.canvas.drawArc(leftTrackArcRect, math.pi / 2, math.pi, false,
          leftTrackSegment.isEmpty ? rightTrackPaint : leftTrackPaint);

    if (!rightTrackArcRect.isEmpty)
      context.canvas.drawArc(rightTrackArcRect, -math.pi / 2, math.pi, false,
          rightTrackSegment.isEmpty ? leftTrackPaint : rightTrackPaint);

    if (!leftTrackSegment.isEmpty)
      context.canvas.drawRect(leftTrackSegment, leftTrackPaint);

    if (!rightTrackSegment.isEmpty)
      context.canvas.drawRect(rightTrackSegment, rightTrackPaint);
  }
}

class TasksSliderThemeData {
  static SliderThemeData get_theme(BuildContext context) {
    return Theme.of(context).sliderTheme.copyWith(
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
          tickMarkShape: SliderTickMarkShape.noTickMark,
          trackHeight: 10,
          trackShape: MyTrachShape(),
        );
  }
}
