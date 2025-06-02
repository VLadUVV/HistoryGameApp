import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/button_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('History Game'),
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
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                        style: buttonStyle().copyWith(
                          minimumSize: WidgetStateProperty.all(Size.fromHeight(50)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset(
                              'assets/images/logo_profile.jpg',
                              width: 80,
                              height: 24,
                            ),
                            Text('Профиль'),
                            SizedBox(width: 8),
                          ],
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
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final savedGame = prefs.getString('saved_game_data');

                          if(savedGame != null) {
                            final saved  = jsonDecode(savedGame);
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                  title: Text('Найдена сохранённая игра'),
                                  content: Text('Эпоха: ${saved['era']}\nИстория: ${saved['historyType']}\nРежим: ${saved['game']}'
                                ),
                            actions: [
                              TextButton(
                                    child: Text('Продолжить'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(
                                        context,
                                        '/${saved['game']}',
                                        arguments: {
                                        'era': saved['era'],
                                        'historyType': saved['historyType'],
                                        'resume': true,
                                        'index': saved['index'],
                                      },
                                    );
                                  },
                                  ),
                              TextButton(
                                child: Text('C начала'),
                                onPressed: () async {
                                  await prefs.remove('saved_game_data');
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/game_selector');
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                Navigator.pushNamed(context, '/game_selector');
                          }
                            },
                        style: buttonStyle().copyWith(minimumSize: WidgetStateProperty.all(Size.fromHeight(50))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset(
                              'assets/images/play.jpg',
                              width: 80,
                              height: 24,
                            ),
                            Text('Новая игра'),
                            SizedBox(width: 8),
                          ],
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
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final savedGame = prefs.getString('saved_game_data');

                          if (savedGame != null) {
                            final saved = jsonDecode(savedGame);
                            Navigator.pushNamed(
                              context,
                              '/${saved['game']}',
                              arguments: {
                                'era': saved['era'],
                                'historyType': saved['historyType'],
                                'resume': true,
                                'index': saved['index'],
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Нет сохранённой игры')),
                            );
                          }
                        },
                        style: buttonStyle().copyWith(
                          minimumSize: WidgetStateProperty.all(Size.fromHeight(50)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset(
                              'assets/images/cont.jpg',
                              width: 80,
                              height: 24,
                            ),
                            Text('Продолжить'),

                          ],
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
