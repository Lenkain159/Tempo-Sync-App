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

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "bpmMin": bpmMin,
      "bpmMax": bpmMax,
      "beat": beat.toJson(),
      "beatsPerBar": beatsPerBar,
      "subdivision": subdivision.toJson(),
      "hitPoints": hitPoints
          .map((hp) => hp.toJson())
          .toList(),
    };
  }

  static Cue fromJson(
    Map<String, dynamic> json,
  ) {
    return Cue(
      name: json["name"],
      bpmMin: (json["bpmMin"] as num).toDouble(),
      bpmMax: (json["bpmMax"] as num).toDouble(),

      beat: NoteValue.fromJson(
        json["beat"],
      ),

      beatsPerBar: json["beatsPerBar"],

      subdivision: NoteValue.fromJson(
        json["subdivision"],
      ),

      hitPoints: (json["hitPoints"] as List)
          .map(
            (hp) => HitPoint.fromJson(hp),
          )
          .toList(),
    );
  }
}