import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kyros/models/note.dart';
import 'package:kyros/screens/audio_screen.dart';
import 'package:kyros/screens/image_screen.dart';
import 'package:kyros/screens/note_screen.dart';
import 'package:kyros/screens/profile_screen.dart';
import 'package:kyros/services/daily_verse_service.dart';
import 'package:kyros/services/database_helper.dart';
import 'package:kyros/widgets/app_drawer.dart';
import 'package:kyros/widgets/expanding_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearchActive = false;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<Note> _notes = [];
  final DailyVerseService _dailyVerseService = DailyVerseService();
  Future<Map<String, String>>? _dailyVerseFuture;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _syncNotes();
    _dailyVerseFuture = _dailyVerseService.getDailyVerse();
  }

  void _loadNotes() async {
    final notes = await DatabaseHelper.instance.readAllNotes();
    setState(() {
      _notes = notes.where((note) => !note.isDeleted).toList();
    });
  }

  void _syncNotes() async {
    if (userId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notes')
          .get();

      final remoteNotes = querySnapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
      final localNotes = await DatabaseHelper.instance.readAllNotes();

      for (final remoteNote in remoteNotes) {
        try {
          final localNote = await DatabaseHelper.instance.readNote(remoteNote.id!);
          if (localNote.createdTime.isBefore(remoteNote.createdTime)) {
            await DatabaseHelper.instance.update(remoteNote);
          } else if (localNote.createdTime.isAfter(remoteNote.createdTime)) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('notes')
                .doc(localNote.id.toString())
                .set(localNote.toMap());
          }
        } catch (e) {
          await DatabaseHelper.instance.create(remoteNote);
        }
      }

      for (final localNote in localNotes) {
        if (!remoteNotes.any((remoteNote) => remoteNote.id == localNote.id)) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('notes')
              .doc(localNote.id.toString())
              .set(localNote.toMap());
        }
      }

      _loadNotes();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
    });
  }

  void _navigateToNotePage({Note? note}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => NoteScreen(note: note, userId: userId),
          ),
        )
        .then((_) => _loadNotes());
  }

  void _pickImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (userId == null || user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    final iconColor = Theme.of(context).appBarTheme.foregroundColor;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.menu, color: iconColor),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: _isSearchActive
            ? const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              )
            : SvgPicture.asset(
                'assets/images/logo.svg',
                height: 94,
                colorFilter: ColorFilter.mode(iconColor!, BlendMode.srcIn),
              ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: iconColor),
            onPressed: _toggleSearch,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: iconColor,
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? Icon(Icons.person, color: appBarColor)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
        ],
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, String>>(
              future: _dailyVerseFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Failed to load daily verse'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No verse available'));
                } else {
                  final verse = snapshot.data!;
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 10),
                      enlargeCenterPage: true,
                    ),
                    items: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                verse['text']!,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                verse['reference']!,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Notes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _notes.isEmpty
                  ? const Center(
                      child: Text(
                        'No notes yet. Tap the + button to add one!',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(note.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (note.labels.isNotEmpty)
                                  Wrap(
                                    spacing: 4.0,
                                    children: note.labels
                                        .map((label) => Chip(
                                              label: Text(label),
                                              padding: EdgeInsets.zero,
                                            ))
                                        .toList(),
                                  ),
                              ],
                            ),
                            onTap: () => _navigateToNotePage(note: note),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ExpandingFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _navigateToNotePage(),
            icon: const Icon(Icons.edit),
            label: 'New Note',
          ),
          ActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioScreen(userId: userId ?? ''),
                ),
              );
            },
            icon: const Icon(Icons.mic),
            label: 'Audio',
          ),
          const SizedBox(height: 8.0),
          ActionButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: 'Image',
          ),
        ],
      ),
    );
  }
}
