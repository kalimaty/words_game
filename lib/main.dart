import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:words_game/GamesScreen.dart';
import 'package:words_game/RouteGenerator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //force landscape screen for user.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      title: 'Words Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamesScreen(),
    );
  }
}
