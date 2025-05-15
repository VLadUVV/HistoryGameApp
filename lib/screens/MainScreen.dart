import 'package:flutter/material.dart';



class MainScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Главный экран')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Профиль"),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            ElevatedButton(
              child: Text("Начать игру"),
              onPressed: () => Navigator.pushNamed(context, '/game_selector'),
            ),
            ElevatedButton(
              child: Text("Продолжить"),
              onPressed: () => Navigator.pushNamed(context, '/game_selector'),
            ),
          ],
        ),
      ),
    );
  }
}



