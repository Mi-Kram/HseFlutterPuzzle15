class WeeklyPuzzleDay {
  const WeeklyPuzzleDay({
    required this.date,
    required this.completed,
    this.moves,
    this.seconds,
  });

  final DateTime date;
  final bool completed;
  final int? moves;
  final int? seconds;
}
