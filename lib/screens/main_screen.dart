import 'package:flutter/material.dart';
import 'package:kyros/screens/bible_screen.dart';
import 'package:kyros/screens/home_screen.dart';
import 'package:kyros/screens/my_wiki_screen.dart';
import 'package:kyros/screens/study_tools_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const BibleScreen(),
      const StudyToolsScreen(),
      const MyWikiScreen(),
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).bottomAppBarTheme.color,
      ),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Bible',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build),
              label: 'Study Tools',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_edu_outlined),
              activeIcon: Icon(Icons.history_edu),
              label: 'My Wiki',
            ),
          ],
        ),
      ),
    );
  }
}
