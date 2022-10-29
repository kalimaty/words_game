import 'package:flutter/material.dart';

class GamesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: Column(
        children: [
          Spacer(),
          Expanded(
              flex: 2,
              child: Icon(
                Icons.videogame_asset,
                size: MediaQuery.of(context).size.width * 0.1,
                color: Colors.white,
              )),
          Expanded(
            child: Text(
              "list of games",
              overflow: TextOverflow.visible,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.white),
            ),
          ),
          Expanded(
              flex: 8,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: GridView.count(
                  padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 30,
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  children: [
                    GameButtonItem(
                      title: "words game",
                      gameRoute: "/words_game_main_screen",
                    ),
                  ],
                ),
              )),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.05,
                      color: Colors.amber.shade800,
                      onPressed: () {
                        Navigator.of(context).pushNamed("/statistics_screen");
                      },
                      icon: Icon(
                        Icons.star,
                      ),
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}

class GameButtonItem extends StatelessWidget {
  final String title;
  final String gameRoute;

  GameButtonItem({required this.title, required this.gameRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(20),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.amber.shade100,
            ),
            onPressed: () => onGamePressed(context),
            child: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.03))));
  }

  void onGamePressed(BuildContext context) {
    Navigator.of(context).pushNamed(gameRoute);
  }
}
