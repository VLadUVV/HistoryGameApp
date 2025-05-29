import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quiz_question.dart';


class QuizScreen extends StatefulWidget {
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> filteredQuestions = [];
  int currentIndex = 0;
  int score = 0;
  int bestScore = 0;
  int timer = 60;
  Timer? countdown;
  bool answered = false;
  int? selectedAnswer;
  final player = AudioPlayer();
  String selectedEra = '';
  String selectedHistoryType = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initQuestions());
  }

  Future<List<QuizQuestion>> loadQuizQuestions() async {
    final String data  = await rootBundle.loadString('assets/data/quiz_questions.json');
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) {
      final question = e['question'];
      final originalAnswers = List<String>.from(e['answers']);
      final correctAnswer = originalAnswers[e['correctIndex']];

      originalAnswers.shuffle();

      final newCorrectIndex = originalAnswers.indexOf(correctAnswer);

      return QuizQuestion (
        question: question,
        answers:  originalAnswers,
        correctIndex: newCorrectIndex,
        era: e['era'],
        historyType: e['historyType'],
      );
    }).toList();
  }

  Future<void> _initQuestions() async{
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    selectedEra = args?['era'] ?? '';
    selectedHistoryType = args?['historyType'] ?? '';
    final bool resume = args?['resume'] ?? false;
    final int savedIndex = args?['index'] ?? 0;

    final allQuestions = await loadQuizQuestions();

    filteredQuestions = allQuestions
    .where((q) => q.era == selectedEra && q.historyType == selectedHistoryType)
    .toList();

    if(filteredQuestions.isEmpty) {
      _showEmptyDialog();
    } else {

      if (resume && savedIndex < filteredQuestions.length) {
        currentIndex = savedIndex;
      }
    }
    await _loadBestScore();
    _startTimer();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_game_data', jsonEncode({
      'game': 'quiz',
      'era': selectedEra,
      'historyType': selectedHistoryType,
      'index': currentIndex + 1,
    }));
  }
  void _showEmptyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          AlertDialog(
            title: Text('Нет вопросов'),
            content: Text('Для выбранной эпохи и направления нет вопросов.'),
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
    void _startTimer() {
      timer = 60;
      countdown?.cancel();
      countdown = Timer.periodic(Duration(seconds: 1),(t){
        setState(() {
          timer--;
          if (timer == 0) {
            t.cancel();
            _handleAnswer(null);
          }
        });
      });
    }
    Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('best_quiz_score') ?? 0;
    });
    }
    Future<void> _saveBestScore() async {
      final prefs = await SharedPreferences.getInstance();
      if (score > bestScore) {
        await prefs.setInt('best_quiz_score', score);
      }
    }
    Future<void> _handleAnswer(int? index) async{
    if(answered) return;
    setState(() {
      answered = true;
      selectedAnswer = index;
      if(index != null && index == filteredQuestions[currentIndex].correctIndex) {
        score++;
        player.play(AssetSource('audio/correct.mp3'));
      } else {
        player.play(AssetSource('audio/wrong.mp3'));
      }
    });

    countdown?.cancel();

    await _saveProgress();
    await Future.delayed(Duration(seconds: 1));

    if(currentIndex < filteredQuestions.length -1) {
      setState(() {
        currentIndex++;
        answered = false;
        selectedAnswer = null;
      });
      _startTimer();
    } else {
      await _saveBestScore();
      _showResultDiolog();
    }
  }
  void _showResultDiolog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_game_data');

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
      title: Text('Результат'),
      content: Text(
        'Вы набрали $score ${pluralize('Очко', score)}'
        'из ${filteredQuestions.length} ${pluralize('Вопрос', filteredQuestions.length)}. \n'
        'Лучший результат: ${score > bestScore ? score : bestScore} ${pluralize('Очко', score >  bestScore ? score : bestScore)}'
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Закрыть')
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
  void dispose() {
    countdown?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    if(filteredQuestions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final question = filteredQuestions[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Квиз'),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      'Вопрос ${currentIndex + 1} из ${filteredQuestions.length}',
                      style: TextStyle(fontSize: 18, fontWeight:  FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Время: $timer ${getSecondLabel(timer)}', style: TextStyle(color: Colors.red, fontSize: 18)),
                  SizedBox(height: 20),
                  Text(question.question, style: TextStyle(fontSize: 20)),
                  SizedBox(height: 24),
                  ...List.generate(question.answers.length, (index) {
                    final isCorrect = index == question.correctIndex;
                    final isSelected = index == selectedAnswer;

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
                            backgroundColor: color.withOpacity(0.7),
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(question.answers[index])
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

