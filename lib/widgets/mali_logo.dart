import 'package:flutter/material.dart';

class MaliLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showText;
  final Color? color;
  final bool useDarkMode;
  final bool responsive;

  const MaliLogo({
    super.key,
    this.width,
    this.height,
    this.showText = true,
    this.color,
    this.useDarkMode = false,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = useDarkMode || 
        (Theme.of(context).brightness == Brightness.dark);
    
    // Using widget-based logo instead of SVG assets

    // Calculate responsive dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    
    double? finalWidth = width;
    double? finalHeight = height;
    
    if (responsive) {
      // Responsive sizing based on screen size
      if (width == null && height == null) {
        // Default responsive sizing
        if (screenWidth < 400) {
          // Small screens (phones in portrait)
          finalWidth = screenWidth * 0.6;
          finalHeight = 40;
        } else if (screenWidth < 600) {
          // Medium screens
          finalWidth = screenWidth * 0.5;
          finalHeight = 50;
        } else {
          // Large screens
          finalWidth = screenWidth * 0.4;
          finalHeight = 60;
        }
      } else if (width != null && height == null) {
        // Width specified, calculate height proportionally
        finalHeight = width! * 0.3; // Maintain aspect ratio
      } else if (height != null && width == null) {
        // Height specified, calculate width proportionally
        finalWidth = height! * 3.33; // Maintain aspect ratio
      }
    }

    return SizedBox(
      width: finalWidth,
      height: finalHeight,
      child: _buildMaliLogoWidget(finalWidth, finalHeight, isDarkMode, color),
    );
  }

  Widget _buildMaliLogoWidget(double? width, double? height, bool isDarkMode, Color? color) {
    final logoColor = color ?? (isDarkMode ? Colors.white : const Color(0xFFEE2B8D));
    final textColor = isDarkMode ? Colors.white : const Color(0xFFEE2B8D);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Symbol - Stylized M/Infinity
        Container(
          width: (height ?? 50) * 0.6,
          height: (height ?? 50) * 0.6,
          decoration: BoxDecoration(
            color: logoColor,
            borderRadius: BorderRadius.circular((height ?? 50) * 0.3),
          ),
          child: Stack(
            children: [
              // Outer shape
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: logoColor,
                    borderRadius: BorderRadius.circular((height ?? 50) * 0.3),
                  ),
                ),
              ),
              // Inner shape
              Positioned(
                top: (height ?? 50) * 0.1,
                left: (height ?? 50) * 0.1,
                right: (height ?? 50) * 0.1,
                bottom: (height ?? 50) * 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFFEE2B8D) : Colors.white,
                    borderRadius: BorderRadius.circular((height ?? 50) * 0.2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Mali Text
        Text(
          'Mali',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: (height ?? 50) * 0.4,
          ),
        ),
      ],
    );
  }
}

class MaliLogoIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool useDarkMode;
  final bool responsive;

  const MaliLogoIcon({
    super.key,
    this.size = 40,
    this.color,
    this.useDarkMode = false,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = useDarkMode || 
        (Theme.of(context).brightness == Brightness.dark);
    
    // Using widget-based logo instead of SVG assets

    // Calculate responsive size
    double finalSize = size;
    if (responsive) {
      final screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth < 400) {
        finalSize = size * 0.8; // Smaller on small screens
      } else if (screenWidth > 800) {
        finalSize = size * 1.2; // Larger on big screens
      }
    }

    return SizedBox(
      width: finalSize,
      height: finalSize,
      child: _buildMaliLogoIcon(finalSize, isDarkMode, color),
    );
  }

  Widget _buildMaliLogoIcon(double size, bool isDarkMode, Color? color) {
    final logoColor = color ?? (isDarkMode ? Colors.white : const Color(0xFFEE2B8D));
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: logoColor,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Stack(
        children: [
          // Outer shape
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: logoColor,
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
            ),
          ),
          // Inner shape
          Positioned(
            top: size * 0.15,
            left: size * 0.15,
            right: size * 0.15,
            bottom: size * 0.15,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFFEE2B8D) : Colors.white,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
