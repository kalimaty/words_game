import 'package:flutter/material.dart';

class KeyboardView extends StatelessWidget {
  final Function(String) onPressed;
  final Function() onEnterPressed;
  final Function() onErasePressed;
  final KeyboardController keyboardController;

  KeyboardView(
      {required this.onPressed,
      required this.onEnterPressed,
      required this.onErasePressed,
      required this.keyboardController});

  @override
  Widget build(BuildContext context) {
    List<String> keys = keyboardController.keys;
    List<Widget> changePos() {
      List<Widget> children = [
        Expanded(
          flex: 2,
          child: ElevatedButton(
              child: Icon(
                Icons.keyboard_return,
                size: MediaQuery.of(context).size.width * 0.02,
              ),
              onPressed: onEnterPressed,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              )),
        ),
        Expanded(
          flex: 2,
          child: ElevatedButton(
              child: Center(
                child: Icon(
                  Icons.highlight_remove,
                  size: MediaQuery.of(context).size.width * 0.02,
                ),
              ),
              onPressed: onErasePressed,
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              )),
        ),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        ...keys
            .map(
              (e) => KeyboardKey(
                letter: e,
                onPressed: onPressed,
              ),
            )
            .toList(),
      ];
      return children;
    }

    return GridView.count(
      shrinkWrap: true,
      reverse: true,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
      crossAxisCount: 12,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      // now just we call one line !
      children: changePos(),

      // before  it  was coding lik this
      /*
       children: [
        KeyboardKey(letter: keys[0], onPressed: onPressed),
        KeyboardKey(letter: keys[1], onPressed: onPressed),
        ElevatedButton(
            child: Icon(
              Icons.highlight_remove,
              size: MediaQuery.of(context).size.width * 0.02,
            ),
            onPressed: onErasePressed,
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
            )),
        ElevatedButton(
            child: Icon(
              Icons.keyboard_return,
              size: MediaQuery.of(context).size.width * 0.02,
            ),
            onPressed: onEnterPressed,
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
            )),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        KeyboardKey(letter: keys[2], onPressed: onPressed),
        KeyboardKey(letter: keys[3], onPressed: onPressed),
        KeyboardKey(letter: keys[4], onPressed: onPressed),
        KeyboardKey(letter: keys[5], onPressed: onPressed),
        KeyboardKey(letter: keys[6], onPressed: onPressed),
        KeyboardKey(letter: keys[7], onPressed: onPressed),
        KeyboardKey(letter: keys[8], onPressed: onPressed),
        KeyboardKey(letter: keys[9], onPressed: onPressed),
        KeyboardKey(letter: keys[10], onPressed: onPressed),
        KeyboardKey(letter: keys[11], onPressed: onPressed),
        KeyboardKey(letter: keys[12], onPressed: onPressed),
        KeyboardKey(letter: keys[13], onPressed: onPressed),
        KeyboardKey(letter: keys[14], onPressed: onPressed),
        KeyboardKey(letter: keys[15], onPressed: onPressed),
        KeyboardKey(letter: keys[16], onPressed: onPressed),
        KeyboardKey(letter: keys[17], onPressed: onPressed),
        KeyboardKey(letter: keys[18], onPressed: onPressed),
        KeyboardKey(letter: keys[19], onPressed: onPressed),
        KeyboardKey(letter: keys[20], onPressed: onPressed),
        KeyboardKey(letter: keys[21], onPressed: onPressed),
        KeyboardKey(letter: keys[22], onPressed: onPressed),
        KeyboardKey(letter: keys[23], onPressed: onPressed),
        KeyboardKey(letter: keys[24], onPressed: onPressed),
        KeyboardKey(letter: keys[25], onPressed: onPressed),
      ],
      */
    );
  }
}

class KeyboardKey extends StatelessWidget {
  final String letter;
  final Function(String) onPressed;
  final Color color;

  KeyboardKey(
      {required this.letter,
      required this.onPressed,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => onPressed(letter),
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.03,
          ),
          textAlign: TextAlign.center,
        ),
        style: ElevatedButton.styleFrom(elevation: 0, primary: color));
  }
}

class KeyboardController {
  List<String> keys = [
    'y',
    'z',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l'
  ];

  void shuffle() {
    keys.shuffle();
  }
}
