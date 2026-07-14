import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        "assets/images/favicon.png",
        height: size,
        width: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
