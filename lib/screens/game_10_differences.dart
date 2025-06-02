import 'package:flutter/material.dart';
import '../models/difference_game.dart';

class Game10DifferencesScreen extends StatefulWidget {
  const Game10DifferencesScreen({super.key});

  @override
  State<Game10DifferencesScreen> createState() => _Game10DifferencesScreenState();
}

class _Game10DifferencesScreenState extends State<Game10DifferencesScreen> {
  late DifferenceGameModel game;
  
  @override
  void initState() {
    super.initState();
    game = DifferenceGameModel(
        imageLeftPath: 'assets/images/level1_left.png',
        imageRightPath: 'assets/images/level1_right.png',
        differences:[
          Difference(x: 0.25, y: 0.3),
          Difference(x: 0.6, y: 0.2),
          Difference(x: 0.8, y: 0.6),
          Difference(x: 0.4, y: 0.7),
          Difference(x: 0.7, y: 0.4),
          Difference(x: 0.5, y: 0.5),
          Difference(x: 0.15, y: 0.8),
          Difference(x: 0.2, y: 0.4),
          Difference(x: 0.9, y: 0.3),
          Difference(x: 0.3, y: 0.6),
        ],
    );
  }
  void handleTap(TapDownDetails details, Size imageSize){
    final local = details.localPosition;
    final x = local.dx / imageSize.width;
    final y = local.dy / imageSize.height;
    setState(() {
      game.checkTap(x, y, 0.05);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Найди 10 отличий'),
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
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              Expanded(
                  child: LayoutBuilder(
                      builder: (context, constraints) {
                        final imageWidth = constraints.maxWidth / 2;
                        return Row(
                          children: [
                            buildImage(game.imageLeftPath, imageWidth),
                            buildImage(game.imageRightPath, imageWidth),
                          ],
                        );
                      },
                  ),
              ),
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    game.isGameComplete
                        ? '🎉 Отличия найдены!'
                        : "Найдено: ${game.foundCount} / 10",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
      ),
    );
  }


  Widget buildImage(String path, double width) {
    return GestureDetector(
      onTapDown: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final offset = renderBox.globalToLocal(details.globalPosition);
        final dx = offset.dx % width;
        final dy = offset.dy - AppBar().preferredSize.height;

        handleTap(
          TapDownDetails(localPosition: Offset(dx, dy)),
          Size(width, width),
        );
      },
      child: Stack(
        children: [
          Image.asset(
            path,
            width: width,
            height: width,
            fit: BoxFit.cover,
          ),
          ...game.differences
                .where((d) => d.found)
                .map((d) => Positioned(
                      left: d.x * width - 15,
                      top: d.y * width - 15,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 3),
                                  ),
                                ),
                              )),
        ],
      ),
    );
  }
}