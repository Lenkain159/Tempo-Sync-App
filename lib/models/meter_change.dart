import 'note_value.dart';

class MeterChange {
  bool enabled;

  bool beforeHit;

  NoteValue beat;

  int beatsPerBar;

  NoteValue subdivision;

  

  MeterChange({
    this.enabled = false,
    this.beforeHit = true,
    required this.beat,
    required this.beatsPerBar,
    required this.subdivision,
  });

  Map<String, dynamic> toJson() {
    return {
      "beat": beat.toJson(),
      "subdivision": subdivision.toJson(),
      "beatsPerBar": beatsPerBar,
      "beforeHit": beforeHit,
    };
  }

  static MeterChange fromJson(Map<String, dynamic> json) {
    return MeterChange(
      beat: NoteValue.fromJson(json["beat"]),
      subdivision: NoteValue.fromJson(json["subdivision"]),
      beatsPerBar: json["beatsPerBar"],
      beforeHit: json["beforeHit"],
    );
  }
}