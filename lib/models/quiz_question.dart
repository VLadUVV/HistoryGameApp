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
}