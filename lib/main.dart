import 'package:flutter/material.dart';
import 'package:flutter_app/screens/main_screen.dart';
import 'package:flutter_app/screens/splash_screen.dart';

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
        // '/profile' : (context) => ProfileScreen(),
        // '/continue' : (context) => ContinueScreen(),
        // '/game_selector' : (context) => GameSelector(),
        // '/game_10_differences' : (context) => Game10Differences(),
        // '/quiz' : (context) => QuizScreen(),
        // '/emoji_guess' : (context) => EmojiGuessScreen(),
        // '/login': (context) => LoginScreen(),
        // '/register': (context) => RegisterScreen(),
        // '/edit_profile': (context) => EditProfileScreen(),
      },
    );
  }
}



