import 'package:flutter/material.dart';
import 'package:kyros/models/wiki_entry.dart';

class WikiEntryScreen extends StatelessWidget {
  final WikiEntry entry;

  const WikiEntryScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(entry.content),
      ),
    );
  }
}
