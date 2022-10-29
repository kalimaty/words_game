import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words_game/WordsGameScreen.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.cyan,
        appBar: AppBar(
          toolbarHeight: 30,
          // backgroundColor: Colors.transparent,
          // shadowColor: Colors.transparent,
          backgroundColor: Colors.cyan,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 10),
            child: Column(
              children: [
                GameStatistic(
                  gameName: "words game",
                  storageName: WordsGameScreen.storageName,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatisticItem extends StatelessWidget {
  final String gameName;
  final double grade;
  final String result;

  const StatisticItem(
      {Key? key,
      required this.gameName,
      required this.grade,
      required this.result})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50 + MediaQuery.of(context).size.height * 0.03,
      child: Card(
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
                flex: 2,
                child: Text(gameName,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.02))),
            Spacer(flex: 5),
            Expanded(
                flex: 3,
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(result,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width * 0.02)),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(
                      grade > 50 ? Icons.star : Icons.star_border,
                      color: Colors.amber.shade800,
                      size: MediaQuery.of(context).size.width * 0.02,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(max(grade, 0.0).toStringAsFixed(2),
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width * 0.02)),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class GameStatistic extends StatefulWidget {
  final String gameName;
  final String storageName;

  GameStatistic({Key? key, required this.gameName, required this.storageName})
      : super(key: key);

  @override
  _GameStatisticState createState() => _GameStatisticState();
}

class _GameStatisticState extends State<GameStatistic> {
  double finalGrade = 0;

  Future<List<StatisticItem>> readResults() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    List<String> grades =
        (_prefs.getStringList(widget.storageName) ?? <String>["-1"]);

    List<StatisticItem> items = [];

    int level = 1;
    for (String gradeString in grades) {
      double grade = double.parse(gradeString);
      String result = "excellent";

      if (grade < 0) {
        result = " no data";
      } else if (grade < 50) {
        result = "Bad";
      } else if (grade < 80) {
        result = "Good";
      }

      items.add(StatisticItem(
          gameName: widget.gameName + "  level " + level.toString(),
          grade: grade,
          result: result));
      level++;
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StatisticItem>>(
      future: readResults(),
      builder:
          (BuildContext context, AsyncSnapshot<List<StatisticItem>> snapshot) {
        if (snapshot.hasData) {
          List<StatisticItem> statisticItems = snapshot.data!;
          return Column(children: statisticItems);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
