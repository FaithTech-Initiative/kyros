import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const _historyKey = 'reading_history';

  static Future<void> addToHistory(String book, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    final entry = '$book $chapter';

    // Avoid duplicates by removing the old entry if it exists
    history.remove(entry);
    history.insert(0, entry);

    // Keep the history to a reasonable size (e.g., 50 entries)
    if (history.length > 50) {
      history.removeLast();
    }

    await prefs.setStringList(_historyKey, history);
  }

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }
}
