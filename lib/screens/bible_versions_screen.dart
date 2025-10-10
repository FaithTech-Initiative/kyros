import 'package:flutter/material.dart';
import 'package:kyros/services/bible_service.dart';
import 'package:provider/provider.dart';

class BibleVersionsScreen extends StatefulWidget {
  const BibleVersionsScreen({super.key});

  @override
  State<BibleVersionsScreen> createState() => _BibleVersionsScreenState();
}

class _BibleVersionsScreenState extends State<BibleVersionsScreen> {
  late final BibleService _bibleService;
  late Future<Map<String, bool>> _downloadedVersionsFuture;
  final Set<String> _downloading = {};

  @override
  void initState() {
    super.initState();
    _bibleService = Provider.of<BibleService>(context, listen: false);
    _loadDownloadedVersions();
  }

  void _loadDownloadedVersions() {
    _downloadedVersionsFuture = _bibleService.getDownloadedVersionsStatus();
  }

  Future<void> _downloadVersion(String versionName) async {
    if (_downloading.contains(versionName)) return;

    setState(() {
      _downloading.add(versionName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading $versionName...')),
    );

    try {
      await _bibleService.downloadBibleVersion(versionName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$versionName downloaded successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download $versionName: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloading.remove(versionName);
          _loadDownloadedVersions(); // Refresh the list
        });
      }
    }
  }

  Future<void> _deleteVersion(String versionName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bible'),
        content: Text('Are you sure you want to delete the $versionName version?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (shouldDelete ?? false) {
      try {
        await _bibleService.deleteBibleVersion(versionName);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$versionName has been deleted.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete $versionName: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _loadDownloadedVersions(); // Refresh the list
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final versions = _bibleService.getAvailableVersions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bibles'),
      ),
      body: FutureBuilder<Map<String, bool>>(
        future: _downloadedVersionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final downloadedStatus = snapshot.data ?? {};

          return ListView.builder(
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final versionName = versions[index];
              final isDownloading = _downloading.contains(versionName);
              final isDownloaded = downloadedStatus[versionName] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(versionName.toUpperCase()),
                  subtitle: Text(
                    isDownloading
                        ? 'Downloading...'
                        : isDownloaded
                            ? 'Downloaded'
                            : 'Not downloaded',
                    style: TextStyle(
                      color: isDownloaded
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                    ),
                  ),
                  trailing: isDownloading
                      ? const CircularProgressIndicator()
                      : isDownloaded
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _deleteVersion(versionName),
                              tooltip: 'Delete',
                            )
                          : IconButton(
                              icon: const Icon(Icons.download_outlined),
                              onPressed: () => _downloadVersion(versionName),
                              tooltip: 'Download',
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
