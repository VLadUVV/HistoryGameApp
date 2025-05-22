import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quiz_question.dart';
import '../button_style.dart';


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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initQuestions());
  }

  void _initQuestions() {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final String era = args?['era'] ?? '';
    final String historyType = args?['historyType'] ?? '';

    filteredQuestions = allQuestions
    .where((q) => q.era == era && q.historyType == historyType)
    .toList();

    if(filteredQuestions.isEmpty) {
      _showEmptyDialog();
    } else {
      _loadBestScore();
      _startTimer();
      setState(() {});
    }
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
  void _showResultDiolog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
      title: Text('Результат'),
      content: Text('Очки: $score\nЛучший результат: ${score > bestScore ? score : bestScore}'),
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
                        : isSelected
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.white;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
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

final List<QuizQuestion> allQuestions = [
  QuizQuestion(
      question: 'В каком году был основан рим?',
      answers: ['753 до н.э.', '500 до н.э.', '1066 н.э.', '1453 н.э.'],
      correctIndex: 0,
      era: 'Античность',
      historyType: 'Мировая история'
  ),
  QuizQuestion(
      question: 'Кто правил в Киевской руси',
      answers: ['Пётр I', 'Иван Грозный', 'Ярослав Мудрый', 'Николай II'],
      correctIndex: 2,
      era: 'Средневековье',
      historyType: 'История России'
  ),
  QuizQuestion(
      question: 'Какое событие произошло в 1917?',
      answers: ['Перестройка', 'Октябрьская революция', 'Вторая мировая', 'Распад СССР'],
      correctIndex: 1,
      era: 'Современность',
      historyType: 'История России'
  ),
  QuizQuestion(
      question: 'с какого события началась эпоха Нового времени?',
      answers: ['Открытие Америки', 'Великая депрессия', 'Февральская революция', 'Падение Рима'],
      correctIndex: 0,
      era: 'Новое время',
      historyType: 'Мировая история'
  ),
];
