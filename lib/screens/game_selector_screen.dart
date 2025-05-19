import 'package:flutter/material.dart';

class GameSelectorScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Выбор режима игры')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/game_10_differences'),
                child: Text('10 отличий'),
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/quiz'),
                child: Text('Викторина'),
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/emoji_guess'),
                child: Text('Угадай события'),
            ),
          ],
        ),
      ),
    );
  }
}