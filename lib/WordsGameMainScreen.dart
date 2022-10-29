import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words_game/LevelItem.dart';
import 'package:words_game/WordsGameScreen.dart';

class WordsGameMainScreen extends StatefulWidget {
  @override
  _WordsGameMainScreenState createState() => _WordsGameMainScreenState();
}

class _WordsGameMainScreenState extends State<WordsGameMainScreen> {
  int width = 4;
  int unlockedLevels = 1;
  late SharedPreferences _prefs;

  Future<int>? levelCount;

  Future<int> countLevels() async {
    int counter = 1;

    while (true) {
      try {
        await DefaultAssetBundle.of(context)
            .loadString("assets/levels/level$counter.json", cache: false);
        counter += 1;
      } catch (e) {
        break;
      }
    }
    _prefs = await SharedPreferences.getInstance();
    unlockedLevels = _prefs.getInt("unlocked_levels") ?? 2;

    return counter - 1;
  }

  @override
  void initState() {
    levelCount = countLevels();
    super.initState();
  }

  List<LevelItem> createLevelItems(int count) {
    List<LevelItem> items = [];
    for (int i = 1; i <= count; i++) {
      items.add(LevelItem(
        i,
        unlocked: i <= unlockedLevels,
        onLevelAccomplished: onLevelAccomplished,
      ));
    }
    return items;
  }

  void onLevelAccomplished(int level) {
    if (level == unlockedLevels) {
      _prefs.setInt("unlocked_levels", level + 1);
      setState(() {
        unlockedLevels = level + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.cyan,
          body: FutureBuilder<int>(
              future: levelCount,
              builder: (context, AsyncSnapshot<int> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    int levels = snapshot.data!;
                    return Column(
                      children: [
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: IconButton(
                                iconSize:
                                    MediaQuery.of(context).size.width * 0.03,
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                ),
                              ),
                            ),
                          ],
                        )),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.text_fields,
                              size: MediaQuery.of(context).size.width * 0.1,
                              color: Colors.white,
                            ),
                          ],
                        )),
                        Spacer(),
                        Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "words game",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      color: Colors.white),
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 8,
                          child: GridView.count(
                            shrinkWrap: true,
                            padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 30,
                            crossAxisCount: width,
                            children: createLevelItems(levels),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.amber.shade100),
                                        onPressed: () {
                                          setState(() {
                                            unlockedLevels = 1;
                                          });
                                          _prefs.setInt("unlocked_levels",
                                              unlockedLevels);
                                          _prefs.remove(
                                              WordsGameScreen.storageName);
                                        },
                                        child: Text(
                                          "Reset",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                        )),
                                  ),
                                )
                              ],
                            ))
                      ],
                    );
                    //start game;
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Couldn't load json files"));
                    //something wrong;
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return Center(child: Text("Something is Wrong"));
              })),
    );
  }
}
