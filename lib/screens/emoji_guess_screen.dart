import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/emoji_question.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuestions());
  }
  void _loadQuestions() {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final String era = args?['era'] ?? '';
    final String historyType = args?['historyType'] ?? '';

    filteredQuestions = allEmojiQuestions
      .where((q) => q.era == era && q.historyType == historyType)
      .toList();

    if(filteredQuestions.isEmpty) {
      _showEmptyDialog();
    } else {
      _loadBestScore();
      _startTimer();
    }
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
  void _showResultDialog() {
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
final List<EmojiQuestion> allEmojiQuestions = [
  // АНТИЧНОСТЬ — МИРОВАЯ ИСТОРИЯ
  EmojiQuestion(
    emojis: '🌋🏛️☠️',
    options: ['Извержение Везувия и гибель Помпей', 'Падение Римской империи', 'Средневековая чума', 'Пожар в Риме'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '🎭🏛️📜',
    options: ['Античная культура', 'Ренессанс', 'Просвещение', 'Средневековье'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '🏛️⚔️👑',
    options: ['Римская республика', 'Александр Македонский', 'Греко-персидские войны', 'Падение Карфагена'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '⚔️🐎🏺',
    options: ['Спарта и Афины', 'Война Роз', 'Троянская война', 'Варфоломеевская ночь'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '🏺📜🏛️',
    options: ['Философия Древней Греции', 'Средневековая теология', 'Ренессансное искусство', 'Просвещение'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'Мировая история',
  ),

  // СРЕДНЕВЕКОВЬЕ — МИРОВАЯ ИСТОРИЯ
  EmojiQuestion(
    emojis: '🛡️⚔️✝️',
    options: ['Крестовые походы', 'Феодальная раздробленность', 'Реформация', 'Куликовская битва'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '🏰👸🗡️',
    options: ['Феодализм', 'Промышленная революция', 'Античная культура', 'Ренессанс'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '⛪🔥📜',
    options: ['Инквизиция', 'Просвещение', 'Великая французская революция', 'Колонизация'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '⚔️🏹🏇',
    options: ['Столетняя война', 'Падение Рима', 'Римская республика', 'Реформация'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '📜📖🕊️',
    options: ['Магна Карта', 'Великая хартия вольностей', 'Период Ренессанса', 'Тридцатилетняя война'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'Мировая история',
  ),

  // НОВОЕ ВРЕМЯ — МИРОВАЯ ИСТОРИЯ
  EmojiQuestion(
    emojis: '🛳️🌍⚓',
    options: ['Открытие Америки', 'Путешествия викингов', 'Великие географические открытия', 'Русско-турецкая война'],
    correctIndex: 2,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '⚙️🏭💡',
    options: ['Индустриализация', 'Просвещение', 'Электрификация', 'Глобализация'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '🧪🔬💉',
    options: ['Научная революция', 'Промышленная революция', 'Ренессанс', 'Античность'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '🏰👑📜',
    options: ['Абсолютизм', 'Феодализм', 'Античность', 'Средневековье'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '📜🗽🕊️',
    options: ['Американская революция', 'Французская революция', 'Российская революция', 'Первая мировая война'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'Мировая история',
  ),

  // СОВРЕМЕННОСТЬ — МИРОВАЯ ИСТОРИЯ
  EmojiQuestion(
    emojis: '📱🖥️🌐',
    options: ['Информационная эпоха', 'Холодная война', 'Космическая гонка', 'Перестройка'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '👩‍🚀🇺🇸🌕',
    options: ['Высадка на Луну', 'Космическая гонка', 'Первый человек в космосе', 'Холодная война'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '💣🌍⚔️',
    options: ['Вторая мировая война', 'Первая мировая война', 'Холодная война', 'Война в Корее'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '🕊️🌍🤝',
    options: ['Создание ООН', 'НАТО', 'Холодная война', 'Вторая мировая война'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'Мировая история',
  ),
  EmojiQuestion(
    emojis: '🌐📈💻',
    options: ['Глобализация', 'Индустриализация', 'Научная революция', 'Ренессанс'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'Мировая история',
  ),

  // АНТИЧНОСТЬ — ИСТОРИЯ РОССИИ
  EmojiQuestion(
    emojis: '🏹🛡️🏞️',
    options: ['Древние славяне', 'Монгольское нашествие', 'Крещение Руси', 'Период княжений'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '🏰🛡️⚔️',
    options: ['Период Киевской Руси', 'Монгольское нашествие', 'Смутное время', 'Эпоха Ивана Грозного'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '⛪✝️🌊',
    options: ['Крещение Руси', 'Монгольское нашествие', 'Основание Москвы', 'Период раздробленности'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '⚔️🐎🌾',
    options: ['Монгольское нашествие', 'Крещение Руси', 'Образование Древнерусского государства', 'Русско-татарская война'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '🛡️🏰👑',
    options: ['Владимир Святославич', 'Ярослав Мудрый', 'Иван Калита', 'Дмитрий Донской'],
    correctIndex: 0,
    era: 'Античность',
    historyType: 'История России',
  ),

  // СРЕДНЕВЕКОВЬЕ — ИСТОРИЯ РОССИИ
  EmojiQuestion(
    emojis: '⚔️🐎🏰',
    options: ['Куликовская битва', 'Ледовое побоище', 'Монгольское нашествие', 'Сто летняя война'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '🕍⛪🎨',
    options: ['Культура Московского княжества', 'Ренессанс', 'Петровские реформы', 'Крещение Руси'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '🏰👑🛡️',
    options: ['Образование Московского государства', 'Период раздробленности', 'Эпоха Ивана Грозного', 'Монгольское нашествие'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '📜🕊️⚔️',
    options: ['Ледовое побоище', 'Реформация', 'Петербургское восстание', 'Феодальная раздробленность'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '👑⚔️🏰',
    options: ['Иван Грозный', 'Пётр I', 'Александр Невский', 'Дмитрий Донской'],
    correctIndex: 0,
    era: 'Средневековье',
    historyType: 'История России',
  ),

  // НОВОЕ ВРЕМЯ — ИСТОРИЯ РОССИИ
  EmojiQuestion(
    emojis: '👑⚔️🛳️',
    options: ['Петровские реформы', 'Великая Отечественная война', 'Крещение Руси', 'Эпоха дворцовых переворотов'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '⚙️🏭🚂',
    options: ['Индустриализация России', 'Крестьянская война', 'Промышленная революция в Европе', 'Русско-японская война'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '📜📈⚖️',
    options: ['Манифест об освобождении крестьян', 'Конституция СССР', 'Декларация независимости', 'Указ о единонаследии'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '🎖️⚔️🏅',
    options: ['Отечественная война 1812 года', 'Русско-турецкая война', 'Крымская война', 'Вторая мировая война'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '👸⚔️🛡️',
    options: ['Екатерина Великая', 'Пётр I', 'Иван Грозный', 'Александр II'],
    correctIndex: 0,
    era: 'Новое время',
    historyType: 'История России',
  ),

  // СОВРЕМЕННОСТЬ — ИСТОРИЯ РОССИИ
  EmojiQuestion(
    emojis: '🚩🔨🌾',
    options: ['Октябрьская революция', 'Коллективизация', 'Индустриализация', 'Перестройка'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '🛠️🚂🏭',
    options: ['Индустриализация СССР', 'Промышленная революция', 'Реформы Александра II', 'Первая мировая война'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '💣🌍⚔️',
    options: ['Великая Отечественная война', 'Первая мировая война', 'Вторая мировая война', 'Гражданская война'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '🧑‍🤝‍🧑✊📜',
    options: ['Перестройка', 'Революция 1905 года', 'Распад СССР', 'Гражданская война'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'История России',
  ),
  EmojiQuestion(
    emojis: '🏛️📉🇷🇺',
    options: ['Распад СССР', 'Образование Российской Федерации', 'Конституция 1993 года', 'Война в Чечне'],
    correctIndex: 0,
    era: 'Современность',
    historyType: 'История России',
  ),
];
