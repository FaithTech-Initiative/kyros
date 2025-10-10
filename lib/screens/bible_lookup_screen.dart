import 'package:flutter/material.dart';
import 'package:kyros/services/bible_service.dart';
import 'package:provider/provider.dart';

class BibleLookupScreen extends StatefulWidget {
  const BibleLookupScreen({super.key});

  @override
  State<BibleLookupScreen> createState() => _BibleLookupScreenState();
}

class _BibleLookupScreenState extends State<BibleLookupScreen> {
  final _referenceController = TextEditingController();
  
  String? _selectedTranslation;
  List<String> _translations = [];

  String _verseText = '';
  String _verseReference = '';
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    final bibleService = Provider.of<BibleService>(context, listen: false);
    _translations = bibleService.getAvailableVersions();
    if (_translations.isNotEmpty) {
      _selectedTranslation = _translations.first;
    }
  }

  Future<void> _lookupVerse() async {
    if (_referenceController.text.isEmpty) {
      if (!mounted) return;
      setState(() {
        _error = 'Please enter a Bible reference.';
      });
      return;
    }

    final bibleService = Provider.of<BibleService>(context, listen: false);
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
      _verseText = '';
      _verseReference = '';
    });

    try {
      final verseData = await bibleService.getVerse(
        _referenceController.text,
        translation: _selectedTranslation,
      );
      if (!mounted) return;
      setState(() {
        _verseText = verseData['text']?.trim() ?? 'Verse text not found.';
        _verseReference = verseData['reference'] ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load verse. Please check the reference and your connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Lookup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'Download Bibles',
            onPressed: () {
              Navigator.of(context).pushNamed('/bible-versions');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTranslation,
                        items: _translations.map((String version) {
                          return DropdownMenuItem<String>(
                            value: version,
                            child: Text(version.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedTranslation = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Bible Version',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Reference (e.g., John 3:16)',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) => _lookupVerse(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                        onPressed: _lookupVerse,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildResultCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Card(
        color: theme.colorScheme.errorContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error,
            style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_verseText.isNotEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _verseReference,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _verseText,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink(); // Return an empty widget if there's no result yet
  }
}
