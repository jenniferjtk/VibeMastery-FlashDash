# Sight Word Practice

A single-user, offline sight-word practice app for early readers (ages 4-8), built for CPSC 4150/6150. Every screen is designed to be usable by a child who cannot yet read instructions: level selection and gameplay communicate entirely through color, icon, size, and animation, with no onboarding text or settings menu.

The app ships with the full Dolch sight word lists ([lib/data/dolch_words.dart](lib/data/dolch_words.dart)) across five levels — Pre-Primer, Primer, First Grade, Second Grade, Third Grade — plus the optional Dolch noun list, and the player picks a level before playing.

## Game implemented

**Flash Dash** — timed flashcards. One word is shown at a time on a large centered card. The player swipes or taps right ("I know it," green check) or left ("practice again," red circle). Missed words recycle to the back of the round's queue until every word has been known at least once, or the 60-second round timer (shown as a shrinking bar, not a number) runs out.

This satisfies the CPSC 4150 requirement of one game implemented well; no other games from the approved menu are included.

## How to run

```bash
flutter pub get
flutter run
```

Requires the Flutter SDK (this project targets Dart `^3.11.5`). No network connection, accounts, or login are required — all data is stored locally on-device via `shared_preferences` and survives app close/reopen.

## Distinctness

This app is distinct from my Solo 3 project and from my team project — it is a new, single-user offline sight-word practice app built from scratch for this exam.

## Tradeoffs

**Scoring model.** I chose normalizing every game to a 0-100 round score and averaging across all entries, over summing raw scores, because different game types (timed, matching, quiz) don't share a natural unit, and an unweighted sum would let a single high-volume game dominate the combined score. The cost of this approach is that it treats every round as equally important regardless of recency or difficulty — a great round from a week ago counts exactly as much as one from today, and there's no credit for streaks or improvement over time. This will hold up until the app needs to reward recent performance or mastery trends over raw averages, at which point a recency-weighted or exponential-moving-average model would be needed instead.

**Persistence.** I chose storing the score history as a single JSON blob in `shared_preferences` over a local SQLite database (`sqflite`), because a single child's play history stays small (well under a megabyte even after months of daily play) and a key-value store needs no schema or migration code for a project this size. The cost of this approach is that every read or write serializes and deserializes the entire history at once, so it wouldn't scale gracefully to years of accumulated data or multiple child profiles sharing one device. This will hold up until the app needs multiple profiles or a history large enough that full-blob reads become noticeably slow, at which point a real embedded database with indexed queries would be needed instead.

**Recycling missed words.** I chose sending a missed word to the back of the round's queue instead of dropping it from the round, because Flash Dash's purpose is repeated exposure until a word is actually known, and dropping missed words would let a child avoid their weakest words entirely. The cost of this approach is that a round front-loaded with misses can run out the clock before every word clears, ending on a lower score even though the child kept trying and never gave up on a word. This will hold up until the app needs a guaranteed-completion mode (an untimed "practice mode"), at which point the round timer would need to become optional per round type.
