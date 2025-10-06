import 'package:flutter/material.dart';

class AudioScreen extends StatelessWidget {
  final String userId;
  const AudioScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio')),
      body: const Center(child: Text('Audio Screen')),
    );
  }
}