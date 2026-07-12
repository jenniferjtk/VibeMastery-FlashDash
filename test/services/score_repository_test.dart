import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibemastery/models/score_entry.dart';
import 'package:vibemastery/services/score_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadEntries returns an empty list on a fresh install (nothing stored)', () async {
    SharedPreferences.setMockInitialValues({});

    final entries = await ScoreRepository().loadEntries();

    expect(entries, isEmpty);
  });

  test('loadEntries falls back to an empty list when the stored value is not valid JSON', () async {
    SharedPreferences.setMockInitialValues({'score_entries': 'not json at all {{{'});

    final entries = await ScoreRepository().loadEntries();

    expect(entries, isEmpty);
  });

  test('loadEntries falls back to an empty list when the stored JSON has the wrong shape', () async {
    // Valid JSON, but an object instead of the expected array of entries.
    SharedPreferences.setMockInitialValues({'score_entries': '{"oops": true}'});

    final entries = await ScoreRepository().loadEntries();

    expect(entries, isEmpty);
  });

  test('loadEntries falls back to an empty list when an entry is missing required fields', () async {
    SharedPreferences.setMockInitialValues({
      'score_entries': '[{"gameId": "flash_dash", "level": "Primer"}]',
    });

    final entries = await ScoreRepository().loadEntries();

    expect(entries, isEmpty);
  });

  test('addEntry persists an entry that a later loadEntries call can read back', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = ScoreRepository();

    await repository.addEntry(ScoreEntry(
      gameId: 'flash_dash',
      level: 'Pre-Primer',
      playedAt: DateTime(2026, 1, 1),
      roundScore: 90,
      wordsTotal: 10,
      wordsKnownFirstTry: 9,
    ));

    final entries = await ScoreRepository().loadEntries();
    expect(entries, hasLength(1));
    expect(entries.first.level, 'Pre-Primer');
    expect(entries.first.roundScore, 90);
  });
}
