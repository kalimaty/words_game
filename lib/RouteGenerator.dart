import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:words_game/GamesScreen.dart';
import 'package:words_game/StatisticsScreen.dart';
import 'package:words_game/WordsGameMainScreen.dart';
import 'package:words_game/WordsGameScreen.dart';


//this class is to navigate between screens easily. //check materialWidget in main file.
class RouteGenerator {
  static Route? generateRoute(RouteSettings settings) {
    List<dynamic> args = [];
    if (settings.arguments != null) {
      args = settings.arguments as List<dynamic>;
    }
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => GamesScreen());
      case '/statistics_screen':
        return MaterialPageRoute(builder: (context) => StatisticsScreen());
      case '/words_game_main_screen':
        return MaterialPageRoute(builder: (context) => WordsGameMainScreen());
      case '/words_game_screen':
        return MaterialPageRoute(
            builder: (context) => WordsGameScreen(
                levelIndex: int.parse(args[0].toString()),
                onLevelAccomplished: args[1] as Function(int)));
    }

    return null;
  }
}
