class TestResult {
  final DateTime date;
  final int score;
  final int total;
  final String mode;

  TestResult({
    required this.date,
    required this.score,
    required this.total,
    required this.mode,
  });

  double get percentage => total > 0 ? score / total : 0.0;
  bool get isPerfect => score == total && total == 40;
  bool get isPassed => score >= 35;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'score': score,
    'total': total,
    'mode': mode,
  };

  factory TestResult.fromJson(Map<String, dynamic> json) => TestResult(
    date: DateTime.parse(json['date']),
    score: json['score'],
    total: json['total'],
    mode: json['mode'],
  );
}
