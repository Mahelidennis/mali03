import 'package:flutter/material.dart';

class MaliLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showText;
  final double textSize;
  final Color? color;

  const MaliLogo({
    super.key,
    this.width,
    this.height,
    this.showText = true,
    this.textSize = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        'assets/images/mali_logo.png',
        fit: BoxFit.contain,
        width: width,
        height: height,
      ),
    );
  }
}