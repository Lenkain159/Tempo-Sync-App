import 'hit_point.dart';
import 'note_value.dart';

class Cue {
  String name;
  double bpmMin;
  double bpmMax;
  double optimalBpm;
  NoteValue beat; // negra, corchea, etc
  int beatsPerBar;
  NoteValue subdivision;
  

  List<HitPoint> hitPoints;

  Cue({
    required this.name,
    required this.bpmMin,
    required this.bpmMax,
    this.optimalBpm = 120,
    required this.beat,
    required this.beatsPerBar,
    required this.subdivision,
    required this.hitPoints,
  });
}