# Prompt Log

### Prompt 1: 

**Prompt:** The complete assignment spec, a single-user, offline Dolch sight-word app for early readers, implementing exactly one game (Flash Dash, timed flashcards with a recycling "know it / practice again" queue), the exact Dolch word lists, the scoring model (`roundScore = round(100 * wordsKnownFirstTry / wordsTotal)`, stored as `ScoreEntry` objects and averaged for a combined score), the four required screens, and the audience constraint that every screen has to work for a non-reading 4-8-year-old.

**Context:** A pre-existing `flutter create .` scaffold (counter demo) in the repo. Explicit instruction to commit after each checkpoint with small, real commits, and to keep a `PROMPT_LOG.md` and `README.md`.

**What happened:** Claude broke the spec into a checkpoint list and started with `lib/data/dolch_words.dart` (the five Dolch levels plus the optional noun list) and the `ScoreEntry`/`ScoreRepository` persistence layer.

**Verification:** Ran a read-only script counting each word list against the spec's exact counts (40/52/41/46/41/95, no duplicates) and `dart analyze` on the new files.


### Prompt 2: 

**Prompt:** Replace the leftover counter-demo scaffold with the real app shell and theme before touching any actual screens. This is the first thing a 4-8-year-old will see, so it needs to read as built for them. Use bright, high-contrast colors, oversized buttons and text, and none of the default Material purple-toolbar styling left over from `flutter create`.

**Context:** Claude wrote `AppTheme.theme` using `base.textTheme.apply(fontSizeFactor: 1.1, bodyColor: ..., displayColor: ...)` to bump default text sizes by 10%.

**What happened:** Running `flutter test` right after threw a real framework assertion, not a hypothetical one:
```
'package:flutter/src/painting/text_style.dart': Failed assertion: line 996 pos 12:
'fontSize != null || (fontSizeFactor == 1.0 && fontSizeDelta == 0.0)': is not true.
```
I told Claude the test was failing, Claude explained that Material 3's default `TextTheme` doesn't guarantee every style has an explicit `fontSize`, so scaling the whole theme by a factor isn't safe. Claude's fix: drop `fontSizeFactor` entirely and keep only the `bodyColor`/`displayColor` overrides.

**Verification:** Re-ran `flutter test`, the smoke test passed with no exception, and `flutter analyze` stayed clean. I accepted the fix; the app still had the intended color/contrast changes, which never depended on `fontSizeFactor`.

---

### Prompt 3: 

**Prompt:** After building the Home screen's level grid, I asked Claude to verify in a browser before calling the checkpoint done, per the project's own "test UI changes in a browser" rule. 

**Context:** Ran a local `flutter run -d chrome` preview , where I verified the six level cards rendered correctly.

**What happened:** Claude clicked a card (several times, with different coordinates and click types) to confirm navigation worked, and nothing happened, the screen never changed. Claude dug into it with `javascript_tool`, found `document.elementFromPoint(...)` at the click coordinates just returns the single `<flutter-view>` canvas host (Flutter web renders everything to one canvas via CanvasKit), and concluded the automated click wasn't being delivered to the app in a way it could hit-test, rather than a bug in the app's tap handling.

**What we agreed:** I decided to switch to widget-test verification (`tester.tap()` plus checking the pushed route/widget), which exercises the exact same `Navigator.push` code path without depending on real pointer delivery.

**Verification:** The widget test tapped the "Pre-Primer" card and asserted the pushed `FlashDashScreen`'s `level.label` was `'Pre-Primer'`, and that the word shown on the resulting `WordCard` belonged to `prePrimerWords`.
---

### Prompt 4: 

**Prompt:** Build the actual gameplay interaction on Flash Dash. Need to have two ways to answer each card, swipe or tap, mapped to a green check ("know it") and a red circle ("practice again"), matching the spec's requirement to use icon plus color rather than text for the choice. And every input handler needs to be debounced and disabled mid-transition.

**Context:** Test used `await tester.tap(knowItButton); await tester.pump(const Duration(milliseconds: 250));` (250ms > the 220ms `AnimatedSwitcher` transition) and then asserted exactly one `WordCard` was on screen.

**What happened:** The test failed:
```
Expected: exactly one matching candidate
Actual: _TypeWidgetFinder:<Found 2 widgets with type "WordCard": [WordCard-[<'sun'>], WordCard-[<'dog'>]]>
```
I asked Claude why a single 250ms pump wasn't enough. Claude's explanation: a single big time-jump advances the animation's *value* to completion, but `AnimatedSwitcher` only removes the outgoing child on a follow-up rebuild triggered by its own status listener, which needs at least one more frame to actually run. Fix: replace the single `pump(250ms)` with `await tester.pumpAndSettle();`.

**Verification:** Re-ran the test, passed, exactly one `WordCard` found after each tap. I accepted `pumpAndSettle()` as the fix at this point.

---

### Prompt 5: `pumpAndSettle()` ran out the round timer instead of settling

**Prompt:** Add the per-round timer next. The spec calls for it to be shown as a shrinking bar or ring defaulting to 60 seconds but configurable as a constant, and the round has to end on whichever comes first.

**Context:** The gameplay-screen tests from the previous checkpoint used `pumpAndSettle()` (see above) to resolve the card-transition animation after each tap.

**What happened:** Once the continuously-running `Ticker` was wired in, those same tests broke again, this time with `Found 0 widgets with type "WordCard"` where 1 was expected. I added a temporary `debugPrint` inside the tick callback and re-ran the failing test to see the actual tick sequence, which showed only two ticks firing but each jumping the clock forward by several seconds. The diagnosis: `pumpAndSettle()` keeps pumping frames until *none* are scheduled, but the round timer's ticker schedules a new frame every tick for the entire round duration, so `pumpAndSettle()` doesn't stop until the round timer itself expires (60s by default), and by then the round was already over.

**What happened (fix):** Claude replaced `pumpAndSettle()` everywhere a `FlashDashScreen` was on screen (the gameplay tests, the Home-to-FlashDash navigation test, and the Home-screen navigation-debounce tests) with a small helper doing several fixed-size `pump()` calls (ex six 50ms pumps) instead of pumping until "settled." Claude also added a dedicated round-timer-expiry test (`roundDuration: const Duration(seconds: 2)`, then `pump(seconds: 3)`) to directly prove the timer-expiry path, once it could no longer accidentally hide behind `pumpAndSettle()`.

**Verification:** Removed the debug print once the fix was confirmed. Ran the full suite (`flutter test`) repeatedly across this and the next few checkpoints, all gameplay-screen tests (debounce, recycling, timer expiry, completion navigation) passed consistently.
---

### Prompt 6:

**Prompt:** Do a full robustness pass across every screen and check whether rapid or repeated taps anywhere (level cards, the stats icon, the home buttons) could push or pop the same screen twice, check whether an empty or missing word list could crash the gameplay screen or leave it stuck with no way forward, confirm every tap target still meets the 64x64 minimum, and confirm a corrupted or missing persisted score file fails cleanly instead of crashing the app on launch.

**Context:** By this point Home, gameplay, Results, and Stats all existed independently. 

**What happened:** Claude found and fixed three real issues each verified with a new test.

1. **Double navigation on rapid taps.** Level cards and the Stats icon on Home used plain `Navigator.push` with no guard, so two fast taps could push the same screen twice before the first push updated the tree. Fix: an `isRouteCurrent()` helper (`ModalRoute.of(context)?.isCurrent`) checked before every push/pop. Test: two rapid taps on "Pre-Primer" (`warnIfMissed: false` on the second tap, since it lands after the first push already covers the widget) result in exactly one `FlashDashScreen` on the stack.

2. **Soft lock on an empty word list.** If `level.words` were ever empty, `FlashDashRound` would report itself complete immediately, but nothing would ever trigger the navigate-to-Results logic (that only fires from the answer handler or the tick callback, neither of which would ever run), so the player would be stuck on a screen with no tap zones and no way forward. Fix: skip round/timer/ticker construction entirely when the list is empty and show a friendly fallback (icon plus `GoHomeButton`) instead. Test: pumping `FlashDashScreen` with an empty-word `DolchLevel` shows the fallback, no `WordCard`/tap zones, no exception, and a way home.

3. **Tap targets below the 64x64 minimum.** Home's stats icon and Stats' AppBar home icon were both plain `IconButton`s relying on Flutter's default 48x48 minimum. Fix: explicit `constraints: BoxConstraints(minWidth: 64, minHeight: 64)` on both.

**Verification:** Added tests for all three (listed above), plus five `ScoreRepository` tests covering a missing key, invalid JSON, wrong-shaped JSON, and entries missing required fields, all falling back to an empty list instead of throwing. Full suite (28 tests) and `flutter analyze` both clean; I reviewed the diffs and accepted all three fixes.

---

### Prompt 7:

**Prompt:** Verify the README: app description, which game was implemented, how to run it, a distinctness line versus the Solo 3 and team project apps, and 2-3 tradeoff statements

**Context:** The scoring-model defense text was specified in the rubric and needed to format the README to be clean and clear on the purpose of the app.

**What happened:** Claude verified the README covering the required sections, plus three tradeoffs.

**Verification:** Read back against the rubric's required README sections to confirm nothing was missing. 