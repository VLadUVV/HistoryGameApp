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

final List<QuizQuestion> allQuestions = [
  // АНТИЧНОСТЬ — ИСТОРИЯ РОССИИ
  QuizQuestion(
    question: 'Какое племя считается предком славян?',
    answers: ['Готы', 'Анты', 'Кельты', 'Саксы'],
    correctIndex: 1,
    era: 'Античность',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Какие племена обитали на территории будущей Руси?',
    answers: ['Анты и склавины', 'Греки', 'Римляне', 'Финикийцы'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'С кем активно торговали восточные славяне?',
    answers: ['С Римом', 'С Китаем', 'С Византией', 'С Египтом'],
    correctIndex: 2,
    era: 'Античность',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Какая религия преобладала у славян в античную эпоху?',
    answers: ['Христианство', 'Язычество', 'Буддизм', 'Ислам'],
    correctIndex: 1,
    era: 'Античность',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Кто такие скифы?',
    answers: ['Цари', 'Военные', 'Кочевники', 'Земледельцы'],
    correctIndex: 2,
    era: 'Античность',
    historyType: 'История России',
  ),

  // АНТИЧНОСТЬ — МИРОВАЯ ИСТОРИЯ
  QuizQuestion(
    question: 'Где зародилась демократия?',
    answers: ['Рим', 'Афины', 'Карфаген', 'Персия'],
    correctIndex: 1,
    era: 'Античность',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Как звали главного бога в Древнем Риме?',
    answers: ['Зевс', 'Юпитер', 'Аполлон', 'Гермес'],
    correctIndex: 1,
    era: 'Античность',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Кто был учителем Александра Македонского?',
    answers: ['Сократ', 'Аристотель', 'Платон', 'Гомер'],
    correctIndex: 1,
    era: 'Античность',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Какое событие произошло в 44 году до н.э.?',
    answers: ['Разгром Карфагена', 'Гибель Цезаря', 'Падение Афин', 'Основание Рима'],
    correctIndex: 1,
    era: 'Античность',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Какая битва считается началом конца Римской республики?',
    answers: ['При Акциуме', 'При Каннах', 'При Гавгамелах', 'При Филиппах'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'Мировая история',
  ),

  // СРЕДНЕВЕКОВЬЕ — ИСТОРИЯ РОССИИ
  QuizQuestion(
    question: 'Кто правил при принятии христианства на Руси?',
    answers: ['Олег', 'Владимир', 'Ярослав', 'Игорь'],
    correctIndex: 1,
    era: 'Средневековье',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Кто основал Москву?',
    answers: ['Иван Калита', 'Юрий Долгорукий', 'Александр Невский', 'Даниил Московский'],
    correctIndex: 1,
    era: 'Средневековье',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Когда началось монголо-татарское вторжение?',
    answers: ['1223', '1240', '1380', '1480'],
    correctIndex: 1,
    era: 'Средневековье',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Где произошло Ледовое побоище?',
    answers: ['На Неве', 'На Чудском озере', 'На Волге', 'На Днепре'],
    correctIndex: 1,
    era: 'Средневековье',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Какой город стал центром объединения русских земель?',
    answers: ['Новгород', 'Киев', 'Москва', 'Владимир'],
    correctIndex: 2,
    era: 'Средневековье',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Оборона чего была прорванна в 2006г до н.э ?',
    answers: ['Дебага', 'Алёшина Александра', 'Охтинки', 'Ютуба'],
    correctIndex: 2,
    era: 'Средневековье',
    historyType: 'История России',
  ),

  // СРЕДНЕВЕКОВЬЕ — МИРОВАЯ ИСТОРИЯ
  QuizQuestion(
    question: 'Кто начал Крестовые походы?',
    answers: ['Папа Римский Урбан II', 'Карл Великий', 'Ричард Львиное Сердце', 'Саладин'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Какой город пал в 1453 году?',
    answers: ['Рим', 'Константинополь', 'Париж', 'Афины'],
    correctIndex: 1,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Кто был основателем ислама?',
    answers: ['Моисей', 'Иисус', 'Мухаммед', 'Будда'],
    correctIndex: 2,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'В каких странах происходила Столетняя война?',
    answers: ['Англия и Франция', 'Испания и Португалия', 'Италия и Германия', 'Россия и Польша'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Как назывался главный враг рыцарей-крестоносцев?',
    answers: ['Карфагеняне', 'Сарацины', 'Греки', 'Скифы'],
    correctIndex: 1,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),

  // НОВОЕ ВРЕМЯ — ИСТОРИЯ РОССИИ
  QuizQuestion(
    question: 'Кто провёл реформу календаря и ввёл Новый год 1 января?',
    answers: ['Пётр I', 'Иван Грозный', 'Николай I', 'Екатерина II'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'В каком году началась Отечественная война?',
    answers: ['1810', '1812', '1815', '1805'],
    correctIndex: 1,
    era: 'Новое время',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Как звали главного реформатора XIX века?',
    answers: ['Павел I', 'Николай II', 'Александр II', 'Иван IV'],
    correctIndex: 2,
    era: 'Новое время',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Какое событие произошло в 1861 году?',
    answers: ['Крепостное право отменено', 'Революция', 'Крымская война', 'Реформа образования'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Кто такая Екатерина II?',
    answers: ['Императрица', 'Министр', 'Генерал', 'Царица Египта'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'История России',
  ),

  // НОВОЕ ВРЕМЯ — МИРОВАЯ ИСТОРИЯ
  QuizQuestion(
    question: 'Кто открыл путь в Индию вокруг Африки?',
    answers: ['Магеллан', 'Колумб', 'Васко да Гама', 'Кортес'],
    correctIndex: 2,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Годы Войны за независимость в США?',
    answers: ['1775–1783', '1812', '1492', '1861–1865'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Кто был первым президентом США?',
    answers: ['Линкольн', 'Вашингтон', 'Джефферсон', 'Адамс'],
    correctIndex: 1,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Когда произошёл Наполеоновский поход в Россию?',
    answers: ['1805', '1812', '1799', '1820'],
    correctIndex: 1,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Великая французская революция - это?',
    answers: ['Реформа', 'Период переворотов и реформ', 'Свержение монархии', 'Война с Англией'],
    correctIndex: 2,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),

  // СОВРЕМЕННОСТЬ — ИСТОРИЯ РОССИИ
  QuizQuestion(
    question: 'Кто проводил политику перестройки?',
    answers: ['Брежнев', 'Горбачёв', 'Путин', 'Ельцин'],
    correctIndex: 1,
    era: 'Современность',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'В каком году была Программа приватизации?',
    answers: ['1991', '1992', '1995', '2000'],
    correctIndex: 1,
    era: 'Современность',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Что произошло в октябре 1993 года?',
    answers: ['Распад СССР', 'Вооружённый конфликт в Москве', 'Выборы Путина', 'Война в Чечне'],
    correctIndex: 1,
    era: 'Современность',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Как называлась военная операция России 1994–1996 гг.?',
    answers: ['Югославия', 'Чечня', 'Афганистан', 'Сирия'],
    correctIndex: 1,
    era: 'Современность',
    historyType: 'История России',
  ),
  QuizQuestion(
    question: 'Кто стал президентом в 2000 году?',
    answers: ['Ельцин', 'Медведев', 'Путин', 'Горбачёв'],
    correctIndex: 2,
    era: 'Современность',
    historyType: 'История России',
  ),

  // СОВРЕМЕННОСТЬ — МИРОВАЯ ИСТОРИЯ
  QuizQuestion(
    question: 'Когда закончилась Вторая мировая война?',
    answers: ['1941', '1945', '1939', '1943'],
    correctIndex: 1,
    era: 'Современность',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Кто был лидером Германии во время Второй мировой?',
    answers: ['Гитлер', 'Сталин', 'Черчилль', 'Рузвельт'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Что такое НАТО?',
    answers: ['Военный союз', 'Экономическое объединение', 'Фонд', 'Научная организация'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Какой из представленных городов был разрушен атомной бомбой?',
    answers: ['Хиросима', 'Токио', 'Пекин', 'Нагоя'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'Мировая история',
  ),
  QuizQuestion(
    question: 'Когда распался СССР?',
    answers: ['1989', '1990', '1991', '1992'],
    correctIndex: 2,
    era: 'Современность',
    historyType: 'Мировая история',
  ),
];
