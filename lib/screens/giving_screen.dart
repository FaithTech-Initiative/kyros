import 'package:flutter/material.dart';

class GivingScreen extends StatelessWidget {
  const GivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giving')),
      body: const Center(child: Text('Giving Screen')),
    );
  }
}