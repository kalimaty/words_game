import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LevelItem extends StatelessWidget {
  final int id;
  final bool unlocked;
  final Function(int) onLevelAccomplished;

  LevelItem(this.id, {required this.unlocked, required this.onLevelAccomplished});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: unlocked ? Colors.amber.shade100 : Colors.deepOrange),
          onPressed: () => unlocked ? onPressed(context) : null,
          child: unlocked
              ? Text(
                  (id).toString(),
                  style: TextStyle(
                      color: Colors.black, fontSize: MediaQuery.of(context).size.width * 0.05),
                )
              : Icon(Icons.lock, size: MediaQuery.of(context).size.width * 0.05)),
    );
  }

  void onPressed(BuildContext context) {
    Navigator.of(context).pushNamed("/words_game_screen", arguments: [id, onLevelAccomplished]);
  }
}
