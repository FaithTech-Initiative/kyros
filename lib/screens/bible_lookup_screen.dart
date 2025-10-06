import 'package:flutter/material.dart';

class BibleLookupScreen extends StatelessWidget {
  const BibleLookupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Lookup')),
      body: const Center(child: Text('Bible Lookup Screen')),
    );
  }
}