import 'package:flutter/material.dart';
import 'package:kyros/services/bible_service.dart';
import 'dart:developer' as developer;

class VersionsScreen extends StatefulWidget {
  const VersionsScreen({super.key});

  @override
  State<VersionsScreen> createState() => _VersionsScreenState();
}

class _VersionsScreenState extends State<VersionsScreen> {
  final BibleService _bibleService = BibleService();
  late Future<Map<String, bool>> _downloadStatus;
  final Map<String, String> _versionFullNames = {
    'bbe': 'Bible in Basic English',
    'kjv': 'King James Version',
    'web': 'World English Bible',
    'oeb-us': 'Open English Bible (US)',
  };

  @override
  void initState() {
    super.initState();
    _refreshDownloadStatus();
  }

  void _refreshDownloadStatus() {
    _downloadStatus = _bibleService.getDownloadedVersionsStatus();
  }

  void _downloadVersion(String version) {
    // Show a dialog or a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Downloading ${_versionFullNames[version] ?? version.toUpperCase()}... This may take a while.')),
    );
    _bibleService.downloadBibleVersion(version).then((_) {
      developer.log('Download finished for $version', name: 'versions.screen');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${_versionFullNames[version] ?? version.toUpperCase()} downloaded successfully!')),
        );
        setState(() {
          _refreshDownloadStatus();
        });
      }
    }).catchError((error, stacktrace) {
      developer.log('Error downloading version',
          name: 'versions.screen', error: error, stackTrace: stacktrace);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading $version.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, bool>>(
        future: _downloadStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            developer.log('Error loading versions status',
                name: 'versions.screen', error: snapshot.error);
            return const Center(child: Text('Error loading versions'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No versions found'));
          }

          final statuses = snapshot.data!;
          final versions = _bibleService.getAvailableVersions();
          final downloaded =
              versions.where((v) => statuses[v] == true).toList();
          final available =
              versions.where((v) => statuses[v] == false).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _refreshDownloadStatus();
              });
            },
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('English'),
                      Icon(Icons.chevron_right, color: Colors.grey[600]),
                    ],
                  ),
                  onTap: () {
                    // TODO: Language selection
                  },
                ),
                if (downloaded.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text('DOWNLOADED',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ...downloaded.map((version) => ListTile(
                      title: Text(
                          _versionFullNames[version] ?? version.toUpperCase()),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {},
                      ),
                      onTap: () {
                        Navigator.pop(context, version);
                      },
                    )),
                if (available.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text('AVAILABLE FOR DOWNLOAD',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ...available.map((version) => ListTile(
                      title: Text(
                          _versionFullNames[version] ?? version.toUpperCase()),
                      trailing: IconButton(
                        icon: const Icon(Icons.download_for_offline_outlined),
                        onPressed: () {
                          _downloadVersion(version);
                        },
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
