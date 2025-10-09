import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kyros/models/note_model.dart';
import 'package:kyros/screens/audio_screen.dart';
import 'package:kyros/screens/image_screen.dart';
import 'package:kyros/screens/note_screen.dart';
import 'package:kyros/screens/profile_screen.dart';
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

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
    });
  }

  void _navigateToNotePage({Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteScreen(note: note, userId: userId),
      ),
    );
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
            : Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 48,
                  colorFilter: ColorFilter.mode(iconColor!, BlendMode.srcIn),
                ),
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
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
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
            Text(
              'Recent Notes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('notes')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notes yet. Tap the + button to add one!',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      final note = Note.fromMap(data, document.id);
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _navigateToNotePage(note: note),
                        ),
                      );
                    }).toList(),
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
