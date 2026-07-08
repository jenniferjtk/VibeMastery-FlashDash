/// Counts down a fixed round duration.
///
/// Pure state, advanced explicitly via [elapse] so it can be driven by a UI
/// ticker (or a test) without depending on dart:async timers itself.
class RoundTimer {
  static const Duration defaultRoundDuration = Duration(seconds: 60);

  final Duration roundDuration;
  Duration _remaining;

  RoundTimer({this.roundDuration = defaultRoundDuration}) : _remaining = roundDuration;

  Duration get remaining => _remaining;

  bool get isExpired => _remaining <= Duration.zero;

  /// Fraction of time left, from 1.0 at round start down to 0.0 at expiry.
  /// Meant to drive a shrinking bar/ring rather than a number a child
  /// would need to read.
  double get remainingFraction {
    if (roundDuration.inMicroseconds == 0) return 0;
    final fraction = _remaining.inMicroseconds / roundDuration.inMicroseconds;
    return fraction.clamp(0.0, 1.0);
  }

  /// Advances the countdown by [delta], never going below zero.
  void elapse(Duration delta) {
    final next = _remaining - delta;
    _remaining = next.isNegative ? Duration.zero : next;
  }
}
