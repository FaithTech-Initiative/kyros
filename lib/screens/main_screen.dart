
import 'package:flutter/material.dart';
import 'package:kyros/widgets/app_drawer.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kyros'),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Welcome to Kyros!'),
      ),
    );
  }
}
