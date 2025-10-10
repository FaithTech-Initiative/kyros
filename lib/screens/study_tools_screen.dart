import 'package:flutter/material.dart';

class StudyToolsScreen extends StatelessWidget {
  const StudyToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Tools'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Daily Verse'),
            onTap: () {
              // TODO: Implement Daily Verse
            },
          ),
          ListTile(
            title: const Text('Prayer Journal'),
            onTap: () {
              // TODO: Implement Prayer Journal
            },
          ),
          ListTile(
            title: const Text('Notebook'),
            onTap: () {
              // TODO: Implement Notebook
            },
          ),
          ListTile(
            title: const Text('Concordance'),
            onTap: () {
              // TODO: Implement Concordance
            },
          ),
        ],
      ),
    );
  }
}
