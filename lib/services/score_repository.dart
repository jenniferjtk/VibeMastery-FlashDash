import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/score_entry.dart';

/// Loads and saves [ScoreEntry] history using on-device local storage.
///
/// A missing or corrupted stored value must never crash the app on launch,
/// so every read falls back to an empty list.
class ScoreRepository {
  static const _prefsKey = 'score_entries';

  Future<List<ScoreEntry>> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addEntry(ScoreEntry entry) async {
    final entries = await loadEntries();
    entries.add(entry);
    await _saveEntries(entries);
  }

  Future<void> _saveEntries(List<ScoreEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_prefsKey, raw);
    } catch (_) {
      // Persistence failure is non-fatal; the round the player just
      // finished simply won't be reflected in future stats screens.
    }
  }
}
