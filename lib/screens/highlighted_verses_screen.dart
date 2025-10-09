import 'package:flutter/material.dart';

class HighlightedVersesScreen extends StatelessWidget {
  const HighlightedVersesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Highlighted Verses'),
      ),
      body: const Center(
        child: Text('Highlighted Verses Screen'),
      ),
    );
  }
}
