import 'hit_point.dart';

class Cue {
  String name;
  double bpmMin;
  double bpmMax;
  double optimalBpm;
  int beatValue; // negra, corchea, etc
  int beatsPerBar;
  int subdivision;
  

  List<HitPoint> hitPoints;

  Cue({
    required this.name,
    required this.bpmMin,
    required this.bpmMax,
    this.optimalBpm = 120,
    required this.beatValue,
    required this.beatsPerBar,
    required this.subdivision,
    required this.hitPoints,
  });
}