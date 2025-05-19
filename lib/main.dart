import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/game_selector_screen.dart';
import 'screens/continue_screen.dart';
import 'screens/game_10_differences.dart';
import 'screens/quiz_screen.dart';
import 'screens/emoji_guess_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'History Game - Историческая игра',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: SplashScreen(),
      routes: {
        '/main' : (context) => MainScreen(),
        '/profile' : (context) => ProfileScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/edit': (context) => EditProfileScreen(),
        '/continue' : (context) => ContinueScreen(),
        '/game_selector' : (context) => GameSelectorScreen(),
        '/game_10_differences' : (context) => Game10Differences(),
        '/quiz' : (context) => QuizScreen(),
        '/emoji_guess' : (context) => EmojiGuessScreen(),

      },
    );
  }
}



