// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:audioplayers/audioplayers.dart';
// import '../models/emoji_question.dart';
//
// class EmojiGuessScreen extends StatefulWidget {
//   @override
//   State<EmojiGuessScreen> createState() => _EmojiGuessScreenState();
// }
//
// class _EmojiGuessScreenState extends State<EmojiGuessScreen> {
//   List<EmojiQuestion> filteredQuestions = [];
//   int currentIndex = 0;
//   int score = 0;
//   int bestScore = 0;
//   int timer = 10;
//   Timer? countdown;
//   bool answered = false;
//   int? selectedAnswer;
//   final player = AudioPlayer();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback(() => _loadQuestions());
//   }
//   void _loadQuestions() {
//     final args = ModalRoute.of(context)!.settings.arguments as Map?;
//     final String era = args?['era'] ?? '';
//     final String historyType = args?['historyType'] ?? '';
//
//     filteredQuestions = allEmojiQuestions
//       .where((q) => q.era == era && q.historyType == historyType)
//       .toList();
//
//     if(filteredQuestions.isEmpty) {
//       _showEmptyDialog();
//     } else {
//       _loadBestScore();
//       _startTimer();
//     }
//   }
//   void _startTimer() {
//     timer = 60;
//     countdown?.cancel();
//     countdown = Timer.periodic(Duration(seconds: 1), (t) {
//       setState(() {
//         timer--;
//         if(timer == 0) {
//           t.cancel();
//           _handleAnser(null);
//         }
//       });
//     });
//   }
//   void _showEmptyDialog() {
//     showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text('Отсутвуют вопросы'),
//           content: Text('Для выбранной эпохи и направления пока нет заданий.'),
//           actions: [
//             TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.pop(context);
//                 },
//                 child: Text('Назад'),
//             ),
//           ],
//         ),
//     );
//   }
//
//   Future<void> _loadBestScore() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       bestScore = prefs.getInt('best_emoji_score', score) ?? 0;
//     });
//   }
//
//   Future<void> _saveBestScore () async {
//     final prefs = await SharedPreferences.getInstance();
//     if (score > bestScore) {
//       await prefs.setInt('best_emoji_score', score);
//     }
//   }
//
//   Future<void> _handleAnswer(int? index) async {
//     if (answered) return;
//
//     setState(() {
//       answered = true;
//       selectedIndex = index;
//       final correct = index != null && index == filteredQuestions[currentIndex].correctIndex;
//       if (correct) {
//         score++;
//         player.play(AssetSource('audio/correct.mp3'));
//       } else {
//         player.play(AssetSource('audio/wrong.mp3'));
//       }
//     });
//
//     countdown?.cancel();
//
//     await Future.delayed(Duration(seconds: 1));
//
//     if (currentIndex < filteredQuestions.length - 1) {
//       setState(() {
//         currentIndex++;
//         answered = false;
//         selectedIndex = null;
//       });
//       _startTimer();
//     } else {
//       await _saveBestScore();
//       _showResultDialog();
//     }
//   }
//   void _showResultDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Игра окончена'),
//         content: Text('Очки: $score\nЛучший результат: ${score > bestScore ? score : bestScore}'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: Text('Закрыть'),
//           ),
//         ],
//       ),
//     );
//   }
//   @override
//   void disponce() {
//     countdown?.cancel();
//     player.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     if(filteredQuestions.isEmpty) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     final question = filteredQuestions[currentIndex];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Угадай событие по эмодзи'),
//         backgroundColor: Colors.deepOrangeAccent,
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/fon_main.jpg'),
//                 fit: BoxFit.cover,
//             ),
//           ),
//         ),
//        Padding(
//          padding: const EdgeInsets.all(24.0),
//          child: Column(
//            children: [
//              Text()
//            ],
//          ),
//        )
//         ],
//       ),
//     ),
//     )
//
//   }
//
// }
