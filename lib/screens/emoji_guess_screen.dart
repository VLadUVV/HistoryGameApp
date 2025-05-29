import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/emoji_question.dart';
import 'package:flutter/services.dart' show rootBundle;

class EmojiGuessScreen extends StatefulWidget {
  @override
  State<EmojiGuessScreen> createState() => _EmojiGuessScreenState();
}

class _EmojiGuessScreenState extends State<EmojiGuessScreen> {
  List<EmojiQuestion> filteredQuestions = [];
  int currentIndex = 0;
  int score = 0;
  int bestScore = 0;
  int timer = 10;
  Timer? countdown;
  bool answered = false;
  int? selectedIndex;
  final player = AudioPlayer();
  String selectedEra = '';
  String selectedHistoryType = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuestions());
  }
  Future<List<EmojiQuestion>> loadEmojiQuestions() async {
    final String data  = await rootBundle.loadString('assets/data/emoji_questions.json');
    final List<dynamic> jsonList = jsonDecode(data);

    return jsonList.map((e) {
      final originalOptions = List<String>.from(e['options']);
      final correctAnswer = originalOptions[e['correctIndex']];

      originalOptions.shuffle();

      final newCorrectIndex = originalOptions.indexOf(correctAnswer);

      return EmojiQuestion(
          emojis: e['emojis'],
          options: originalOptions,
          correctIndex: newCorrectIndex,
          era: e['era'],
          historyType: e['historyType'],
      );
    }).toList();
  }
  void _loadQuestions() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    selectedEra = args?['era'] ?? '';
    selectedHistoryType = args?['historyType'] ?? '';
    final bool resume = args?['resume'] ?? false;
    final int savedIndex = args?['index'] ?? 0;

    final allQuestions = await loadEmojiQuestions();

    filteredQuestions = allQuestions
      .where((q)
          => q.era == selectedEra && q.historyType == selectedHistoryType)
      .toList();

    if(filteredQuestions.isEmpty) {
      _showEmptyDialog();
    } else {
      if(resume && savedIndex < filteredQuestions.length) {
        currentIndex = savedIndex;
      }
    }
    _loadBestScore();
    _startTimer();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_game_data', jsonEncode({
      'game': 'emoji_guess',
      'era': selectedEra,
      'historyType': selectedHistoryType,
      'index': currentIndex + 1,
    }));
  }

  void _startTimer() {
    timer = 60;
    countdown?.cancel();
    countdown = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        timer--;
        if(timer == 0) {
          t.cancel();
          _handleAnswer(null);
        }
      });
    });
  }
  void _showEmptyDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Отсутвуют вопросы'),
          content: Text('Для выбранной эпохи и направления пока нет заданий.'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Назад'),
            ),
          ],
        ),
    );
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('best_emoji_score') ?? 0;
    });
  }

  Future<void> _saveBestScore () async {
    final prefs = await SharedPreferences.getInstance();
    if (score > bestScore) {
      await prefs.setInt('best_emoji_score', score);
    }
  }


  Future<void> _handleAnswer(int? index) async {
    if (answered) return;

    setState(() {
      answered = true;
      selectedIndex = index;
      final correct = index != null && index == filteredQuestions[currentIndex].correctIndex;
      if (correct) {
        score++;
        player.play(AssetSource('audio/correct.mp3'));
      } else {
        player.play(AssetSource('audio/wrong.mp3'));
      }
    });

    countdown?.cancel();

    await _saveProgress();
    await Future.delayed(Duration(seconds: 2));

    if (currentIndex < filteredQuestions.length - 1) {
      setState(() {
        currentIndex++;
        answered = false;
        selectedIndex = null;
      });
      _startTimer();
    } else {
      await _saveBestScore();
      _showResultDialog();
    }
  }

  void _showResultDialog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_game_data');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Игра окончена'),
        content: Text(
            'Вы набрали $score ${pluralize('Очко', score)}'
            ' из ${filteredQuestions.length} ${pluralize('Вопрос', filteredQuestions.length)}. \n'
            'Лучший результат: ${score > bestScore ? score : bestScore} ${pluralize('Очко', score >  bestScore ? score : bestScore)}'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  String getSecondLabel(int number) {
    final n = number % 100;
    if (n >= 11 && n <= 14) return 'секунд';
    switch (n % 10) {
      case 1:
        return 'секунда';
      case 2:
      case 3:
      case 4:
        return 'секунды';
      default:
        return 'секунд';
    }
  }

  String pluralize(String word, int number) {
    final n = number % 100;
    if (n >= 11 && n <= 14) {
      return word == 'вопрос' ? 'вопросов' : 'очков';
    }
    switch (n % 10) {
      case 1:
        return word;
      case 2:
      case 3:
      case 4:
        return word == 'вопрос' ? 'вопроса' : 'очка';
      default:
        return word == 'вопрос' ? 'вопросов' : 'очков';
    }
  }

  @override
  void disponce() {
    countdown?.cancel();
    player.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(filteredQuestions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final question = filteredQuestions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Угадай событие по эмодзи'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fon_main.jpg'),
                fit: BoxFit.cover,
            ),
          ),
        ),
       Padding(
         padding: const EdgeInsets.all(24.0),
         child: Column(
           children: [
             Text('Время: $timer сек', style: TextStyle(color: Colors.red)),
             SizedBox(height: 20),
             Text(question.emojis, style: TextStyle(fontSize: 40)),
             SizedBox(height: 24),
             ...List.generate(question.options.length, (index) {
               final isCorrect = index == question.correctIndex;
               final isSelected = index == selectedIndex;
               final color = !answered
                   ?Colors.white
                   : isCorrect
                       ? Colors.green
                       : isSelected
                         ? Colors.red
                         : Colors.white;
               return Container(
                 margin: EdgeInsets.symmetric(vertical: 6),
                 width: double.infinity,
                 child: ElevatedButton(
                     onPressed: () => _handleAnswer(index),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: color.withOpacity(0.8),
                       foregroundColor: Colors.black,
                       padding: EdgeInsets.symmetric(vertical: 14),
                     ),
                     child: Text(question.options[index]),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
