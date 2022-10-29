import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

class Word {
  String english;
  String arabic;
  String soundPath;
  String imagePath;
  late AudioSource audio;

  Image? image;
  Word(this.english, this.arabic, this.soundPath, this.imagePath);

  Word.fromJson(Map<String, dynamic> json)
      : english = json['english'],
        arabic = json['arabic'],
        soundPath = json['sound_path'],
        imagePath = json['image_path'];

  Map<String, dynamic> toJson() => {
        'english': english,
        'arabic': arabic,
        'sound_path': soundPath,
        'image_path': imagePath,
      };

  String toString() {
    return english + " means " + arabic;
  }
}
