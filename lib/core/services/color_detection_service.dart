import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../domain/entities/fresh_item.dart';
import '../../domain/entities/color_detection_result.dart';

class ColorDetectionService {
  static const double _confidenceThreshold = 0.6;

  /// Analyzes the camera image data to detect sticker color and determine freshness
  ColorDetectionResult analyzeImage(Uint8List imageBytes) {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Get the center region of the image for analysis (assuming sticker is centered)
      final centerX = image.width ~/ 2;
      final centerY = image.height ~/ 2;
      final regionSize = (image.width * 0.3).toInt(); // 30% of image width

      // Extract colors from center region
      final colors = _extractColorsFromRegion(
        image,
        centerX,
        centerY,
        regionSize,
      );

      // Analyze dominant colors
      final detectionResult = _analyzeDominantColors(colors);

      return detectionResult;
    } catch (e) {
      // Return default result if analysis fails
      return ColorDetectionResult(
        detectedStatus: FreshnessStatus.fresh,
        colorName: 'Unknown',
        confidence: 0.0,
        detectionTime: DateTime.now(),
      );
    }
  }

  List<ColorInfo> _extractColorsFromRegion(
    img.Image image,
    int centerX,
    int centerY,
    int regionSize,
  ) {
    final colors = <ColorInfo>[];
    final halfRegion = regionSize ~/ 2;

    final startX = (centerX - halfRegion).clamp(0, image.width - 1);
    final endX = (centerX + halfRegion).clamp(0, image.width - 1);
    final startY = (centerY - halfRegion).clamp(0, image.height - 1);
    final endY = (centerY + halfRegion).clamp(0, image.height - 1);

    for (int y = startY; y < endY; y += 3) {
      // Sample every 3rd pixel for performance
      for (int x = startX; x < endX; x += 3) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        colors.add(ColorInfo(r: r, g: g, b: b));
      }
    }

    return colors;
  }

  ColorDetectionResult _analyzeDominantColors(List<ColorInfo> colors) {
    if (colors.isEmpty) {
      return ColorDetectionResult(
        detectedStatus: FreshnessStatus.fresh,
        colorName: 'Unknown',
        confidence: 0.0,
        detectionTime: DateTime.now(),
      );
    }

    // Count occurrences of each color category
    int greenCount = 0;
    int yellowCount = 0;
    int purpleCount = 0;

    for (final color in colors) {
      final category = _categorizeColor(color);
      switch (category) {
        case ColorCategory.green:
          greenCount++;
          break;
        case ColorCategory.yellow:
          yellowCount++;
          break;
        case ColorCategory.purple:
          purpleCount++;
          break;
        case ColorCategory.other:
          // Skip other colors
          break;
      }
    }

    final totalColors = colors.length;
    final greenRatio = greenCount / totalColors;
    final yellowRatio = yellowCount / totalColors;
    final purpleRatio = purpleCount / totalColors;

    // Determine dominant color and freshness status
    if (greenRatio >= _confidenceThreshold) {
      return ColorDetectionResult(
        detectedStatus: FreshnessStatus.fresh,
        colorName: 'Green',
        confidence: greenRatio,
        detectionTime: DateTime.now(),
      );
    } else if (yellowRatio >= _confidenceThreshold) {
      return ColorDetectionResult(
        detectedStatus: FreshnessStatus.useSoon,
        colorName: 'Yellow',
        confidence: yellowRatio,
        detectionTime: DateTime.now(),
      );
    } else if (purpleRatio >= _confidenceThreshold) {
      return ColorDetectionResult(
        detectedStatus: FreshnessStatus.spoiled,
        colorName: 'Purple',
        confidence: purpleRatio,
        detectionTime: DateTime.now(),
      );
    } else {
      // If no color meets threshold, pick the highest ratio
      if (greenRatio >= yellowRatio && greenRatio >= purpleRatio) {
        return ColorDetectionResult(
          detectedStatus: FreshnessStatus.fresh,
          colorName: 'Green',
          confidence: greenRatio,
          detectionTime: DateTime.now(),
        );
      } else if (yellowRatio >= purpleRatio) {
        return ColorDetectionResult(
          detectedStatus: FreshnessStatus.useSoon,
          colorName: 'Yellow',
          confidence: yellowRatio,
          detectionTime: DateTime.now(),
        );
      } else {
        return ColorDetectionResult(
          detectedStatus: FreshnessStatus.spoiled,
          colorName: 'Purple',
          confidence: purpleRatio,
          detectionTime: DateTime.now(),
        );
      }
    }
  }

  ColorCategory _categorizeColor(ColorInfo color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    // Convert to HSV for better color analysis
    final hsv = _rgbToHsv(r, g, b);
    final hue = hsv.h;
    final saturation = hsv.s;
    final value = hsv.v;

    // Skip very dark or very light colors (likely shadows or highlights)
    if (value < 0.2 || value > 0.9 || saturation < 0.3) {
      return ColorCategory.other;
    }

    // Green: hue 60-180 degrees
    if (hue >= 60 && hue <= 180 && g > r && g > b) {
      return ColorCategory.green;
    }

    // Yellow: hue 30-90 degrees
    if (hue >= 30 && hue <= 90 && (r + g) > 1.5 * b) {
      return ColorCategory.yellow;
    }

    // Purple/Violet: hue 240-300 degrees
    if ((hue >= 240 && hue <= 300) || (b > g && (r + b) > 1.2 * g)) {
      return ColorCategory.purple;
    }

    return ColorCategory.other;
  }

  HSV _rgbToHsv(int r, int g, int b) {
    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;

    final max = [rNorm, gNorm, bNorm].reduce((a, b) => a > b ? a : b);
    final min = [rNorm, gNorm, bNorm].reduce((a, b) => a < b ? a : b);
    final delta = max - min;

    double hue = 0;
    if (delta != 0) {
      if (max == rNorm) {
        hue = 60 * ((gNorm - bNorm) / delta % 6);
      } else if (max == gNorm) {
        hue = 60 * ((bNorm - rNorm) / delta + 2);
      } else {
        hue = 60 * ((rNorm - gNorm) / delta + 4);
      }
    }

    final saturation = max == 0 ? 0.0 : delta / max;
    final value = max;

    return HSV(h: hue, s: saturation, v: value);
  }
}

class ColorInfo {
  final int r, g, b;

  ColorInfo({required this.r, required this.g, required this.b});
}

class HSV {
  final double h, s, v;

  HSV({required this.h, required this.s, required this.v});
}

enum ColorCategory { green, yellow, purple, other }
