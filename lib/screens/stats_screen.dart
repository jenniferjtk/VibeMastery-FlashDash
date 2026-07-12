import 'package:flutter/material.dart';

import '../models/score_entry.dart';
import '../services/score_repository.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_guard.dart';
import '../widgets/score_visual.dart';

const Map<String, String> _gameDisplayNames = {
  'flash_dash': 'Flash Dash',
};

String _displayNameForGame(String gameId) => _gameDisplayNames[gameId] ?? gameId;

String _formatDate(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Per-game score history and the combined score across every game ever
/// played. New games need no changes here — they just need to show up as
/// [ScoreEntry] rows with their own gameId.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ScoreRepository _repository = ScoreRepository();
  late final Future<List<ScoreEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _repository.loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, size: 32),
          constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
          onPressed: () {
            if (!isRouteCurrent(context)) return;
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<ScoreEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data ?? const <ScoreEntry>[];
            if (entries.isEmpty) {
              return const _EmptyStatsView();
            }
            return _StatsList(entries: entries);
          },
        ),
      ),
    );
  }
}

/// Friendly fallback shown before any round has ever been played, instead
/// of a blank screen or an error.
class _EmptyStatsView extends StatelessWidget {
  const _EmptyStatsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 96, color: Color(0xFFFFD43B)),
            const SizedBox(height: 16),
            Text(
              'No rounds played yet!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsList extends StatelessWidget {
  final List<ScoreEntry> entries;

  const _StatsList({required this.entries});

  int get _combinedScore {
    final total = entries.fold<int>(0, (sum, e) => sum + e.roundScore);
    return (total / entries.length).round();
  }

  Map<String, List<ScoreEntry>> get _byGame {
    final map = <String, List<ScoreEntry>>{};
    for (final entry in entries) {
      map.putIfAbsent(entry.gameId, () => []).add(entry);
    }
    for (final list in map.values) {
      list.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final byGame = _byGame;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        Center(child: ScoreVisual(score: _combinedScore)),
        const SizedBox(height: 8),
        Center(
          child: Text('Combined Score', style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 32),
        for (final gameId in byGame.keys) ...[
          Text(_displayNameForGame(gameId), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...byGame[gameId]!.map((entry) => _ScoreEntryTile(entry: entry)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _ScoreEntryTile extends StatelessWidget {
  final ScoreEntry entry;

  const _ScoreEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(entry.level),
        subtitle: Text(_formatDate(entry.playedAt)),
        trailing: Text(
          '${entry.roundScore}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}
