
import 'package:just_audio/just_audio.dart';
import 'package:words_game/DataObjects/Word.dart';

class Level {
  final List<Word> words;
  final int remainingTime;

  Level(this.words, this.remainingTime);

  Level.fromJson(Map<String, dynamic> json)
      : words = (json["words"] as List).map((wordJson) => Word.fromJson(wordJson)).toList(),
        remainingTime = json["remaining_time"] as int;

  void loadSounds() async {
    for(Word word in words){

      word.audio = AudioSource.uri(Uri.parse("asset:///${word.soundPath}"));
    }
  }

  void shuffleWords() {
    words.shuffle();
  }
}
