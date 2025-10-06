import 'package:flutter/material.dart';
import 'package:kyros/widgets/app_drawer.dart';

class MainScreen extends StatelessWidget {
  final String userId;
  const MainScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kyros'),
      ),
      drawer: AppDrawer(userId: userId),
      body: const Center(
        child: Text('Welcome to Kyros!'),
      ),
    );
  }
}
