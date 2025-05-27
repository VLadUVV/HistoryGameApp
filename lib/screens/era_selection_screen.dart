import 'package:flutter/material.dart';
import 'package:flutter_app/button_style.dart';

class EraSelectionScreen extends StatefulWidget{
  @override
  _EraSelectionScreenState createState() => _EraSelectionScreenState();
}

class _EraSelectionScreenState extends State<EraSelectionScreen> {
  String? selectedEra;
  String? selectedHistory;
  String? selectedGame;

  final List<String> eras = ['Античность', 'Средневековье', 'Новое время', 'Современность'];
  final List<String> histories = ['История России', 'Мировая история'];

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    selectedGame = args?['game'];
  }

  void proceedToGames() {
    if(selectedEra != null && selectedHistory != null && selectedGame != null) {
      Navigator.pushNamed(
          context,
          '/$selectedGame',
          arguments: {
            'era' : selectedEra,
            'historyType' : selectedHistory,
          },
        );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, выберите эпоху и тип истории')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('Выбор эпохи и истории'),
      backgroundColor: Colors.deepOrangeAccent,
      centerTitle: true,
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
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Выберите историческую эпоху:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ...eras.map((era) => RadioListTile<String>(
                  title: Text(era),
                  value: era,
                  groupValue: selectedEra,
                  onChanged: (value){
                    setState(() {
                      selectedEra = value;
                    });
                  },
                )),
                SizedBox(height: 16),
                Text('Выберите направление:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                ...histories.map((history) => RadioListTile<String>(
                      title: Text(history),
                      value: history,
                      groupValue: selectedHistory,
                      onChanged: (value) {
                        setState(() {
                          selectedHistory = value;
                        });
                      },
                  )),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: proceedToGames,
                    child: Text('Продолжить'),
                    style: buttonStyle(),
                  ),
              ],
            ),
          ),
    ],
    ),
    );
  }
}