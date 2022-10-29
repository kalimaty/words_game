import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words_game/DataObjects/Level.dart';
import 'package:words_game/DataObjects/Word.dart';
import 'package:words_game/KeyboardView.dart';

class WordsGameScreen extends StatefulWidget {
  static const String storageName = "words_game";

  final int levelIndex;
  final Function(int) onLevelAccomplished;

  WordsGameScreen(
      {required this.levelIndex, required this.onLevelAccomplished});

  @override
  _WordsGameScreenState createState() => _WordsGameScreenState();
}

class _WordsGameScreenState extends State<WordsGameScreen>
    with TickerProviderStateMixin {
  Future<Level?>? _levelFuture;
  String _input = "";
  Timer? _timer;
  Word? _currentWord;
  Level? _level;
  int _remainingTime = 30;
  int _wrongAnswers = 0;
  int _correctAnswers = 0;
  int _wordsCounter = 0;
  bool _isMuted = false;
  AudioPlayer _player = AudioPlayer();
  //animate the image from left to right.

  KeyboardController _keyboardController = new KeyboardController();

  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  //load level from json using the index given above.
  Future<Level?> loadLevel() async {
    var json = await DefaultAssetBundle.of(context).loadString(
        "assets/levels/level${widget.levelIndex}.json",
        cache: true);
    Map<String, dynamic> jsonMap = jsonDecode(json);

    Level level = Level.fromJson(jsonMap);
    level.shuffleWords();
    level.loadSounds();

    return level;
  }

  @override
  void initState() {
    _levelFuture = loadLevel();
    super.initState();
  }

  //when user presses any letter on GUI keyboard
  void onKeyboardLetterPressed(String value) {
    setState(() {
      _input += value;
    });
  }

  //when user presses on Enter button on GUI keyboard
  void onKeyboardEnterPressed() {
    //check if the player had the right answer.
    if (_input.toLowerCase() == _currentWord!.english.toLowerCase()) {
      _correctAnswers += 1;
    } else {
      _wrongAnswers += 1;
    }

    if (_wordsCounter == _level!.words.length) {
      onGameFinished();
    }
    //restart input field and change question.
    setState(() {
      changeQuestion();
    });
  }

  //when user presses Remove on GUI keyboard
  void onKeyboardErasePressed() {
    if (_input.length > 0) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  //restart timer using this function, make sure to call _timer.cancel() before calling this
  // function. (if there was another timer running)
  void startTimer() {
    //restart timer
    _remainingTime = _level!.remainingTime;

    if (_timer != null) {
      _timer!.cancel();
    }

    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_remainingTime == 0) {
          onKeyboardEnterPressed();
        } else {
          setState(() {
            _remainingTime--;
          });
        }
      },
    );
  }

  //when all words in the level are seen. either by timeout or by an explicit answer from user.
  void onGameFinished() async {
    //calculate result
    int grade = (_correctAnswers * 100 / _wordsCounter).floor();

    //add statistics
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String>? grades =
        _prefs.getStringList(WordsGameScreen.storageName) ?? [];

    if (widget.levelIndex > grades.length) {
      grades.add(grade.toString());
    } else {
      grades[widget.levelIndex - 1] = grade.toString();
    }
    _prefs.setStringList(WordsGameScreen.storageName, grades);
    //end statistics addition

    String resultText = "Hard luck!";

    _player.setVolume(_isMuted ? 0 : 1);
    //success condition, this could potentially lead to open the next level.
    if (grade > 50) {
      if (grade < 60) {
        resultText = "Average";
      } else if (grade < 80) {
        resultText = "Good";
        _player.setAsset("assets/sounds/good_applause.wav");
      } else {
        _player.setAsset("assets/sounds/excellent_applause.wav");
        resultText = "Excellent";
      }
      widget.onLevelAccomplished(widget.levelIndex);
    } else {
      _player.setAsset("assets/sounds/lose_sound.wav");
    }

    _player.play();

    if (_timer != null) {
      _timer!.cancel();
    }

    //open a dialog for the user to show him results, and suggest him to go back to main menu.
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.2,
              child: Column(
                children: [
                  Center(
                    child: new Text(
                      resultText,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.03),
                    ),
                  ),
                  Center(
                      child: Text(
                    grade.toString() + "%",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.03),
                  )),
                ],
              ),
            ),
            content: IconButton(
                iconSize: MediaQuery.of(context).size.height * 0.1,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.refresh,
                )),
          );
        });
  }

  //when user clicks on mute sound.
  void muteSound() {
    _isMuted = !_isMuted;
  }

  //this function is called on time out or when user presses Enter.
  void changeQuestion() {
    //shuffle keyboard
    _keyboardController.shuffle();

    _input = "";
    List<Word> words = _level!.words;

    if (_wordsCounter == words.length) {
      return;
    }

    _currentWord = words[_wordsCounter];
    startTimer();

    _player.setVolume(_isMuted ? 0 : 1);
    _player.setAudioSource(_currentWord!.audio);
    _player.play();

    animationController.reset();
    animationController.forward();
    _wordsCounter++;
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.cyan,
          body: FutureBuilder<Level?>(
            future: _levelFuture,
            builder: (context, AsyncSnapshot<Level?> snapshot) {
              if (snapshot.hasData) {
                _level = snapshot.data;
                if (_currentWord == null) {
                  changeQuestion();
                }
                return Stack(children: [
                  PositionedTransition(
                    rect: RelativeRectTween(
                            begin: RelativeRect.fromSize(
                                Rect.fromLTWH(-100, 0, 100, 100),
                                Size(100, 100)),
                            end: RelativeRect.fromSize(
                                Rect.fromLTWH(
                                    MediaQuery.of(context).size.width * 0.4,
                                    0,
                                    150,
                                    150),
                                Size(100, 100)))
                        .animate(animationController),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              flex: 2,
                              child: Image.asset(
                                _currentWord!.imagePath,
                                // fit: BoxFit.fill,
                                width: MediaQuery.of(context).size.width * 0.3,
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                              ),
                            ),
                            Spacer(flex: 6),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            iconSize: MediaQuery.of(context).size.width * 0.03,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Text(
                                (_wordsCounter).toString() +
                                    "/" +
                                    _level!.words.length.toString(),
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Icon(
                              Icons.timer,
                              size: MediaQuery.of(context).size.width * 0.03,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Text(_remainingTime.toString(),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                  color: Colors.white)),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.close,
                            color: Colors.red,
                            size: MediaQuery.of(context).size.width * 0.03,
                          ),
                          Text(_wrongAnswers.toString(),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                  color: Colors.red)),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.done,
                            color: Colors.green,
                            size: MediaQuery.of(context).size.width * 0.03,
                          ),
                          Text(_correctAnswers.toString(),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                  color: Colors.green)),
                        ],
                      ),
                      const SizedBox(
                        width: 300,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            iconSize: MediaQuery.of(context).size.width * 0.03,
                            icon: Icon(
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                              color: _isMuted ? Colors.red : Colors.white,
                              textDirection: TextDirection.rtl,
                            ),
                            onPressed: muteSound,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Spacer(flex: 5),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Spacer(flex: 2),
                            // Expanded(
                            //   flex: 2,
                            //   child: ElevatedButton(
                            //       child: Center(
                            //         child: Icon(
                            //           Icons.highlight_remove,
                            //           size:
                            //               MediaQuery.of(context).size.width *
                            //                   0.02,
                            //         ),
                            //       ),
                            //       onPressed: onKeyboardErasePressed,
                            //       style: ElevatedButton.styleFrom(
                            //         primary: Colors.red,
                            //       )),
                            // ),
                            Spacer(flex: 4),

                            Expanded(
                              flex: 4,
                              child: Card(
                                margin: EdgeInsets.fromLTRB(10, 0, 60, 0),
                                child: Text(
                                  _input,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   width: 5,
                            // ),
                            // Expanded(
                            //   flex: 2,
                            //   child: ElevatedButton(
                            //       child: Icon(
                            //         Icons.keyboard_return,
                            //         size: MediaQuery.of(context).size.width *
                            //             0.02,
                            //       ),
                            //       onPressed: onKeyboardEnterPressed,
                            //       style: ElevatedButton.styleFrom(
                            //         primary: Colors.green,
                            //       )),
                            // ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 4,
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 60, 0),
                                child: Text(
                                  _currentWord!.arabic,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        flex: 6,
                        child: KeyboardView(
                          onPressed: onKeyboardLetterPressed,
                          onEnterPressed: onKeyboardEnterPressed,
                          onErasePressed: onKeyboardErasePressed,
                          keyboardController: _keyboardController,
                        ),
                      ),
                    ],
                  ),
                ]);
                //start game;
              } else if (snapshot.hasError) {
                return Center(child: Text("Couldn't load json file"));
                //something wrong;
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          )),
    );
  }
}
