import 'package:flutter/material.dart';

class ThreeJsBridge extends StatelessWidget {
  final String configJson;

  const ThreeJsBridge({super.key, required this.configJson});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Three.js is only supported on Web platform.',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
