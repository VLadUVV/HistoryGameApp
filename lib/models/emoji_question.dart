class EmojiQuestion {
  final String emojis;
  final List<String> options;
  final int correctIndex;
  final String era;
  final String historyType;

  EmojiQuestion({
    required this.emojis,
    required this.options,
    required this.correctIndex,
    required this.era,
    required this.historyType,
  });

  factory EmojiQuestion.fromJson(Map<String, dynamic> json) {
    return EmojiQuestion(
      emojis: json['emojis'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
      era: json['era'],
      historyType: json['historyType'],
    );
  }
}