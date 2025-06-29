// ignore_for_file: use_super_parameters

import 'dart:math';

import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatefulWidget {
  const CustomLoadingIndicator({Key? key}) : super(key: key);

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double angle = _controller.value * 2 * 3.1415926535;
          return Transform.rotate(
            angle: angle,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(8, (i) {
                final double rad = (3.1415926535 * 2 / 8) * i;
                final double dx = 18 * (1.15 * (i % 2 == 0 ? 1.0 : 0.8)) * cos(rad);
                final double dy = 18 * (1.15 * (i % 2 == 0 ? 1.0 : 0.8)) * sin(rad);
                final double size = i % 2 == 0 ? 10.0 : 7.0;
                final Color color = Color.lerp(const Color(0xFF2962FF), const Color(0xFF4F8CFF), i / 8)!;
                return Positioned(
                  left: 24 + dx,
                  top: 24 + dy,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
