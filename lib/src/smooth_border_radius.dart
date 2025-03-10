import 'package:flutter/rendering.dart';

import 'path_smooth_corners.dart';
import 'processed_smooth_radius.dart';
import 'smooth_radius.dart';

class SmoothBorderRadius extends BorderRadius {
  SmoothBorderRadius({
    required double cornerRadius,
    bool useCache = true,
    double cornerSmoothing = 0,
  }) : this.only(
          useCache: useCache,
          topLeft: SmoothRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: cornerSmoothing,
          ),
          topRight: SmoothRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: cornerSmoothing,
          ),
          bottomLeft: SmoothRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: cornerSmoothing,
          ),
          bottomRight: SmoothRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: cornerSmoothing,
          ),
        );

  /// Creates a border radius where all radii are [radius].

  const SmoothBorderRadius.all(
    SmoothRadius radius, {
    bool useCache = true,
  }) : this.only(
          useCache: useCache,
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        );

  /// Creates a vertically symmetric border radius where the top and bottom
  /// sides of the rectangle have the same radii.
  const SmoothBorderRadius.vertical({
    SmoothRadius top = SmoothRadius.zero,
    SmoothRadius bottom = SmoothRadius.zero,
    bool useCache = true,
  }) : this.only(
          topLeft: top,
          topRight: top,
          bottomLeft: bottom,
          bottomRight: bottom,
          useCache: useCache,
        );

  /// Creates a horizontally symmetrical border radius where the left and right
  /// sides of the rectangle have the same radii.
  const SmoothBorderRadius.horizontal({
    SmoothRadius left = SmoothRadius.zero,
    SmoothRadius right = SmoothRadius.zero,
    bool useCache = true,
  }) : this.only(
          useCache: useCache,
          topLeft: left,
          topRight: right,
          bottomLeft: left,
          bottomRight: right,
        );

  /// Creates a border radius with only the given non-zero values. The other
  /// corners will be right angles.
  const SmoothBorderRadius.only({
    this.topLeft = SmoothRadius.zero,
    this.topRight = SmoothRadius.zero,
    this.bottomLeft = SmoothRadius.zero,
    this.bottomRight = SmoothRadius.zero,
    this.useCache = true,
  }) : super.only(
          topLeft: topLeft,
          bottomRight: topRight,
          topRight: topRight,
          bottomLeft: bottomLeft,
        );

  /// Returns a copy of this BorderRadius with the given fields replaced with
  /// the new values.
  SmoothBorderRadius copyWith({
    Radius? topLeft,
    Radius? topRight,
    Radius? bottomLeft,
    Radius? bottomRight,
    bool? useCache,
  }) {
    return SmoothBorderRadius.only(
      useCache: useCache ?? this.useCache,
      topLeft: topLeft is SmoothRadius ? topLeft : this.topLeft,
      topRight: topRight is SmoothRadius ? topRight : this.topRight,
      bottomLeft: bottomLeft is SmoothRadius ? bottomLeft : this.bottomLeft,
      bottomRight: bottomRight is SmoothRadius ? bottomRight : this.bottomRight,
    );
  }

  /// A border radius with all zero radii.
  static const SmoothBorderRadius zero =
      SmoothBorderRadius.all(SmoothRadius.zero);

  /// The top-left [SmoothRadius].
  final SmoothRadius topLeft;

  /// The top-right [SmoothRadius].
  final SmoothRadius topRight;

  /// The bottom-left [SmoothRadius].
  final SmoothRadius bottomLeft;

  /// The bottom-right [SmoothRadius].
  final SmoothRadius bottomRight;

  /// Whether to use the cache when creating the [Path].
  final bool useCache;

  /// Creates a [Path] inside the given [Rect].
  Path toPath(Rect rect) {
    final width = rect.width;
    final height = rect.height;

    final result = Path();

    /// Calculating only if values are different
    final processedTopLeft = ProcessedSmoothRadius(
      topLeft,
      width: width,
      height: height,
      useCache: useCache,
    );
    final processedBottomLeft = topLeft == bottomLeft
        ? processedTopLeft
        : ProcessedSmoothRadius(
            bottomLeft,
            width: width,
            height: height,
            useCache: useCache,
          );
    final processedBottomRight = bottomLeft == bottomRight
        ? processedBottomLeft
        : ProcessedSmoothRadius(
            bottomRight,
            width: width,
            height: height,
            useCache: useCache,
          );
    final processedTopRight = topRight == bottomRight
        ? processedBottomRight
        : ProcessedSmoothRadius(
            topRight,
            width: width,
            height: height,
            useCache: useCache,
          );

    result
      ..addSmoothTopRight(processedTopRight, rect)
      ..addSmoothBottomRight(processedBottomRight, rect)
      ..addSmoothBottomLeft(processedBottomLeft, rect)
      ..addSmoothTopLeft(processedTopLeft, rect);

    return result.transform(
      Matrix4.translationValues(rect.left, rect.top, 0).storage,
    );
  }

  @override
  BorderRadiusGeometry subtract(BorderRadiusGeometry other) {
    if (other is SmoothBorderRadius) return this - other;
    return super.subtract(other);
  }

  @override
  BorderRadiusGeometry add(BorderRadiusGeometry other) {
    if (other is SmoothBorderRadius) return this + other;
    return super.add(other);
  }

  /// Returns the difference between two [BorderRadius] objects.
  SmoothBorderRadius operator -(BorderRadius other) {
    if (other is SmoothBorderRadius)
      return SmoothBorderRadius.only(
        useCache: useCache,
        topLeft: (topLeft - other.topLeft) as SmoothRadius,
        topRight: (topRight - other.topRight) as SmoothRadius,
        bottomLeft: (bottomLeft - other.bottomLeft) as SmoothRadius,
        bottomRight: (bottomRight - other.bottomRight) as SmoothRadius,
      );

    return this;
  }

  /// Returns the sum of two [BorderRadius] objects.
  SmoothBorderRadius operator +(BorderRadius other) {
    if (other is SmoothBorderRadius) {
      return SmoothBorderRadius.only(
        useCache: useCache,
        topLeft: (topLeft + other.topLeft) as SmoothRadius,
        topRight: (topRight + other.topRight) as SmoothRadius,
        bottomLeft: (bottomLeft + other.bottomLeft) as SmoothRadius,
        bottomRight: (bottomRight + other.bottomRight) as SmoothRadius,
      );
    }
    return this;
  }

  /// Returns the [BorderRadius] object with each corner negated.
  ///
  /// This is the same as multiplying the object by -1.0.
  @override
  SmoothBorderRadius operator -() {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: (-topLeft) as SmoothRadius,
      topRight: (-topRight) as SmoothRadius,
      bottomLeft: (-bottomLeft) as SmoothRadius,
      bottomRight: (-bottomRight) as SmoothRadius,
    );
  }

  /// Scales each corner of the [BorderRadius] by the given factor.
  @override
  SmoothBorderRadius operator *(double other) {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: topLeft * other,
      topRight: topRight * other,
      bottomLeft: bottomLeft * other,
      bottomRight: bottomRight * other,
    );
  }

  /// Divides each corner of the [BorderRadius] by the given factor.
  @override
  SmoothBorderRadius operator /(double other) {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: topLeft / other,
      topRight: topRight / other,
      bottomLeft: bottomLeft / other,
      bottomRight: bottomRight / other,
    );
  }

  /// Integer divides each corner of the [BorderRadius] by the given factor.
  @override
  SmoothBorderRadius operator ~/(double other) {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: topLeft ~/ other,
      topRight: topRight ~/ other,
      bottomLeft: bottomLeft ~/ other,
      bottomRight: bottomRight ~/ other,
    );
  }

  /// Computes the remainder of each corner by the given factor.
  @override
  SmoothBorderRadius operator %(double other) {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: topLeft % other,
      topRight: topRight % other,
      bottomLeft: bottomLeft % other,
      bottomRight: bottomRight % other,
    );
  }

  /// Linearly interpolate between two [BorderRadius] objects.
  ///
  /// If either is null, this function interpolates from [BorderRadius.zero].
  ///
  /// {@macro dart.ui.shadow.lerp}
  static SmoothBorderRadius? lerp(
      SmoothBorderRadius? a, SmoothBorderRadius? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b!.copyWith(useCache: false) * t;
    if (b == null) return a.copyWith(useCache: false) * (1.0 - t);
    return SmoothBorderRadius.only(
      useCache: false, // Caching is disabled while lerping
      topLeft: SmoothRadius.lerp(a.topLeft, b.topLeft, t)!,
      topRight: SmoothRadius.lerp(a.topRight, b.topRight, t)!,
      bottomLeft: SmoothRadius.lerp(a.bottomLeft, b.bottomLeft, t)!,
      bottomRight: SmoothRadius.lerp(a.bottomRight, b.bottomRight, t)!,
    );
  }

  @override
  BorderRadius resolve(TextDirection? direction) => BorderRadius.only(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      );

  @override
  String toString() {
    if (topLeft == topRight &&
        topLeft == bottomRight &&
        topLeft == bottomLeft) {
      final radius = topLeft.toString();
      return 'SmoothBorderRadius${radius.substring(12)}';
    }

    return 'SmoothBorderRadius('
        'topLeft: $topLeft,'
        'topRight: $topRight,'
        'bottomLeft: $bottomLeft,'
        'bottomRight: $bottomRight,'
        ')';
  }
}
