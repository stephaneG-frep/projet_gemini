enum FocusSessionResult { completed, abandoned, penalized }

class FocusSession {
  const FocusSession({
    required this.startedAt,
    this.endedAt,
    this.durationMinutes = 25,
    this.result,
  });

  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMinutes;
  final FocusSessionResult? result;
}
