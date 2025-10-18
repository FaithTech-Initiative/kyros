import 'package:flutter/material.dart';
import 'package:kyros/services/database_helper.dart';
import 'package:kyros/services/firestore_service.dart';
import 'package:kyros/screens/chapter_selection_screen.dart';
import 'package:kyros/screens/bible_versions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BibleReferencesScreen extends StatefulWidget {
  final String? book;
  final int? chapter;
  final int? initialVerse;

  const BibleReferencesScreen({
    super.key,
    this.book,
    this.chapter,
    this.initialVerse,
  });

  @override
  State<BibleReferencesScreen> createState() => _BibleReferencesScreenState();
}

class _BibleReferencesScreenState extends State<BibleReferencesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _book = 'John';
  int _chapter = 1;
  int? _selectedVerse;
  String _translation = 'ESV_bible';
  List<Map<String, dynamic>> _verses = [];
  bool _isLoading = true;
  int _chapterCount = 0;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    if (widget.book != null && widget.chapter != null) {
      _book = widget.book!;
      _chapter = widget.chapter!;
      _selectedVerse = widget.initialVerse;
      _loadVerses();
    } else {
      _loadLastRead();
    }
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _book = prefs.getString('last_read_book') ?? 'John';
      _chapter = prefs.getInt('last_read_chapter') ?? 1;
      _translation = prefs.getString('active_translation') ?? 'ESV_bible';
      _selectedVerse = widget.initialVerse;
    });
    _loadVerses();
  }

  Future<void> _saveLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read_book', _book);
    await prefs.setInt('last_read_chapter', _chapter);
  }

  Future<void> _loadVerses() async {
    setState(() {
      _isLoading = true;
    });
    final verses = await _firestoreService.getVerses(_translation, _book, _chapter);
    final chapterCount = await _firestoreService.getChapterCount(_translation, _book);
    setState(() {
      _verses = verses;
      _chapterCount = chapterCount;
      _isLoading = false;
    });
    _saveLastRead();

    if (_selectedVerse != null && _verses.isNotEmpty) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_itemScrollController.isAttached) {
          _itemScrollController.jumpTo(
            index: _selectedVerse! - 1,
            alignment: 0.5, // Center the item
          );
        }
      });
    }
  }

  void _previousChapter() {
    if (_chapter > 1) {
      setState(() {
        _chapter--;
        _selectedVerse = null;
      });
      _loadVerses();
    }
  }

  void _nextChapter() {
    if (_chapter < _chapterCount) {
      setState(() {
        _chapter++;
        _selectedVerse = null;
      });
      _loadVerses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.volume_up_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BibleVersionsScreen()),
                );
                _loadLastRead();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: 4),
                  Text(_translation.replaceAll('_bible', '').toUpperCase()),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              Padding(
                 padding: const EdgeInsets.symmetric(vertical: 20.0),
                 child: Column(
                   children: [
                     Text(
                       _book,
                       style: GoogleFonts.ebGaramond(fontSize: 24),
                     ),
                     Text(
                       '$_chapter',
                       style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                     ),
                   ],
                 ),
              ),
              Padding(
                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                 child: Text(
                   "The Word Became Flesh", 
                   textAlign: TextAlign.center,
                   style: GoogleFonts.ebGaramond(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                 ),
              ),
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemCount: _verses.length,
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  itemBuilder: (context, index) {
                    final verse = _verses[index];
                    final verseNumber = verse[DatabaseHelper.columnVerse];
                    final isSelected = verseNumber == _selectedVerse;

                    return _buildVerseItem(verse, isSelected);
                  },
                ),
              ),
            ], 
          ),
      bottomNavigationBar: BottomAppBar(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.play_arrow_outlined), onPressed: () {}),
              Row(
                children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previousChapter, iconSize: 30),
                    TextButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterSelectionScreen(
                            book: _book,
                            chapterCount: _chapterCount,
                          ),
                        ),
                      );
                      if (result != null && result is int) {
                        setState(() {
                          _chapter = result;
                          _selectedVerse = null;
                        });
                        _loadVerses();
                      }
                    },
                     style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                         foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    child: Text('$_book $_chapter', style: const TextStyle(fontSize: 16)),
                    ),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextChapter, iconSize: 30),
                ],
              ),
              const SizedBox(width: 40) // to balance the play icon
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseItem(Map<String, dynamic> verse, bool isSelected) {
    final verseColor = isSelected 
      ? Theme.of(context).textTheme.bodyLarge?.color 
      : Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedVerse = verse[DatabaseHelper.columnVerse];
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
               padding: const EdgeInsets.only(top: 6.0),
               child: Text(
                '${verse[DatabaseHelper.columnVerse]}',
                style: TextStyle(fontSize: 12, color: verseColor),
            ),
             ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.ebGaramond(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    fontSize: 20,
                    height: 1.5,
                    color: verseColor,
                  ),
                  children: [
                    TextSpan(
                      text: verse[DatabaseHelper.columnText],
                    )
                  ]
                ),
              )
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 16, color: Colors.grey,),
              onPressed: () {
                // copy verse text
              },
            )
          ],
        ),
      ),
    );
  }
}
