import 'package:flutter/material.dart';
import 'package:kyros/services/database_helper.dart';
import 'package:kyros/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleVersionsScreen extends StatefulWidget {
  const BibleVersionsScreen({super.key});

  @override
  BibleVersionsScreenState createState() => BibleVersionsScreenState();
}

class BibleVersionsScreenState extends State<BibleVersionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> _availableTranslationsFuture;
  final Set<String> _downloadedTranslations = {};
  String? _activeTranslation;
  final Map<String, bool> _downloading = {};

  @override
  void initState() {
    super.initState();
    _availableTranslationsFuture = _firestoreService.getAvailableTranslations();
    _loadDownloadedTranslations();
    _loadActiveTranslation();
  }

  Future<void> _loadDownloadedTranslations() async {
    final downloaded = await DatabaseHelper.instance.getAvailableTranslations();
    setState(() {
      _downloadedTranslations.addAll(downloaded);
    });
  }

  Future<void> _loadActiveTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeTranslation = prefs.getString('active_translation') ?? 'ESV_bible';
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
    try {
      // This is a simplified download trigger.
      // We'll fetch the first chapter of the first book to confirm it works.
      await _firestoreService.getVerses(translation, 'Genesis', 1);
      final prefs = await SharedPreferences.getInstance();
      final downloaded = await DatabaseHelper.instance.getAvailableTranslations();
      await prefs.setStringList('downloaded_translations', downloaded);
      setState(() {
        _downloadedTranslations.clear();
        _downloadedTranslations.addAll(downloaded);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sorry, something went wrong :(')),
      );
    } finally {
      setState(() {
        _downloading[translation] = false;
      });
    }
  }

  String _getTranslationFullName(String translationCode) {
    switch (translationCode) {
      case 'ESV_bible':
        return 'English Standard Version 2016';
      case 'NLT_bible':
        return 'New Living Translation';
      case 'NIV_bible':
        return 'New International Version';
      case 'KJV_bible':
        return 'King James Version';
      case 'NKJV_bible':
        return 'New King James Version';
      case 'AMP_bible':
        return 'Amplified Bible';
      default:
        return translationCode.replaceAll('_bible', '').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bible'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
              final translationData = availableTranslations[index];
              final translation = translationData['name'] as String;
              final isDownloaded = _downloadedTranslations.contains(translation);
              final isActive = _activeTranslation == translation;
              final isDownloading = _downloading[translation] ?? false;
              final fullName = _getTranslationFullName(translation);
              final shortName = translation.replaceAll('_bible', '');

              return GestureDetector(
                onTap: isDownloaded ? () => _setActiveTranslation(translation) : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.lightBlue.withAlpha(51) : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shortName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(fullName),
                            const Text('English'),
                          ],
                        ),
                      ),
                      if (isDownloading)
                        const CircularProgressIndicator()
                      else if (isActive)
                        const Icon(Icons.check, color: Colors.blue)
                      else if (!isDownloaded)
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadTranslation(translation),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
