import 'package:flutter/material.dart';

import '../button_style.dart';


class GameSelectorScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(title: Text('Выбор режима игры'),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
        elevation: 4,
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
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: .0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGameButton(context, screenWidth, '10 отличий', 'game_10_differences'),
                  SizedBox(height: 16),
                  _buildGameButton(context, screenWidth, 'Quiz', 'quiz'),
                  SizedBox(height: 16),
                  _buildGameButton(context, screenWidth, 'Угадай событие', 'emoji_guess'),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGameButton(BuildContext context, double width, String title, String gameRoute) {
    return Opacity(
        opacity: 0.5,
        child: SizedBox(
          width: width * 0.6,
          child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                  context,
                  '/select_era',
                  arguments: {'game' : gameRoute},
              ),
            child: Text(title),
            style: buttonStyle().copyWith(
              minimumSize: WidgetStateProperty.all(Size.fromHeight(50)),
            ),
          ),
        ),
    );
  }
}
