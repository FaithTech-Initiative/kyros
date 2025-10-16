import 'package:flutter/material.dart';
import 'package:kyros/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleVersionsScreen extends StatefulWidget {
  const BibleVersionsScreen({super.key});

  @override
  BibleVersionsScreenState createState() => BibleVersionsScreenState();
}

class BibleVersionsScreenState extends State<BibleVersionsScreen> {
  late Future<List<String>> _availableTranslationsFuture;
  final Set<String> _downloadedTranslations = {};
  String? _activeTranslation;
  final Map<String, bool> _downloading = {};

  @override
  void initState() {
    super.initState();
    _availableTranslationsFuture = _getAvailableTranslations();
    _loadDownloadedTranslations();
    _loadActiveTranslation();
  }

  Future<List<String>> _getAvailableTranslations() async {
    return await DatabaseHelper.instance.getAvailableTranslations();
  }

  Future<void> _loadDownloadedTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList('downloaded_translations') ?? [];
    setState(() {
      _downloadedTranslations.addAll(downloaded);
    });
  }

  Future<void> _loadActiveTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeTranslation = prefs.getString('active_translation') ?? 'kjv';
    });
  }

  Future<void> _setActiveTranslation(String translation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_translation', translation);
    setState(() {
      _activeTranslation = translation;
    });
  }

  Future<void> _downloadTranslation(String translation) async {
    setState(() {
      _downloading[translation] = true;
    });
    await DatabaseHelper.instance.loadNewTranslation(translation);
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList('downloaded_translations') ?? [];
    downloaded.add(translation);
    await prefs.setStringList('downloaded_translations', downloaded);
    setState(() {
      _downloadedTranslations.add(translation);
      _downloading[translation] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Versions'),
      ),
      body: FutureBuilder<List<String>>(
        future: _availableTranslationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final availableTranslations = snapshot.data ?? [];
          return ListView.builder(
            itemCount: availableTranslations.length,
            itemBuilder: (context, index) {
              final translation = availableTranslations[index];
              final isDownloaded = _downloadedTranslations.contains(translation);
              final isActive = _activeTranslation == translation;
              final isDownloading = _downloading[translation] ?? false;
              return ListTile(
                title: Text(translation.toUpperCase()),
                trailing: isDownloading
                    ? const CircularProgressIndicator()
                    : isDownloaded
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => _downloadTranslation(translation),
                          ),
                onTap: isDownloaded ? () => _setActiveTranslation(translation) : null,
                tileColor: isActive ? Colors.blue.withAlpha(51) : null,
              );
            },
          );
        },
      ),
    );
  }
}
