// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class Dot extends StatelessWidget {
  final Color color;
  final double size;
  const Dot({required this.color, required this.size, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
