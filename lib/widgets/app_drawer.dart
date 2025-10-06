import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyros/screens/about_screen.dart';
import 'package:kyros/screens/archived_notes_screen.dart';
import 'package:kyros/screens/collections_screen.dart';
import 'package:kyros/screens/giving_screen.dart';
import 'package:kyros/screens/help_and_feedback_screen.dart';
import 'package:kyros/screens/highlighted_verses_screen.dart';
import 'package:kyros/screens/profile_screen.dart';
import 'package:kyros/screens/settings_screen.dart';
import 'package:kyros/screens/trash_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GivingScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onPrimary,
                        backgroundColor: theme.colorScheme.primary,
                        side: BorderSide(
                            color: theme.colorScheme.onPrimary, width: 1.0),
                      ),
                      child: const Text('Give Now'),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileScreen()));
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.displayName ?? 'No Name',
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user?.email ?? 'No Email',
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.collections_bookmark),
              title: const Text('Collections'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CollectionsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Highlights'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const HighlightedVersesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ArchivedNotesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Trash'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TrashScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text('Giving'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const GivingScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Feedback'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HelpAndFeedbackScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}
