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
                  Opacity(
                    opacity: 0.5,
                    child: SizedBox(
                      width: screenWidth * 0.6,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(
                                context, '/game_10_differences'),
                        child: Text('10 отличий'),
                        style: buttonStyle().copyWith(
                          minimumSize: WidgetStateProperty.all(Size.fromHeight(
                              50)),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Opacity(
                    opacity: 0.5,
                    child: SizedBox(
                      width: screenWidth * 0.6,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/quiz'),
                        child: Text('Квиз'),
                        style: buttonStyle().copyWith(
                          minimumSize: WidgetStateProperty.all(Size.fromHeight(
                              50)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Opacity(
                    opacity: 0.5,
                    child: SizedBox(
                      width: screenWidth * 0.6,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/emoji_guess'),
                        child: Text('Угадай события'),
                        style: buttonStyle().copyWith(
                          minimumSize: WidgetStateProperty.all(Size.fromHeight(
                              50)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
