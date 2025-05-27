class QuizQuestion {
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String era;
  final String historyType;

  QuizQuestion({
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.era,
    required this.historyType,
});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correctIndex: json['correctIndex'],
      era: json['era'],
      historyType: json['historyType'],
    );
  }
}