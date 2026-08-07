import 'cue.dart';

class TempoProject {

  double fps;

  List<Cue> cues;

  TempoProject({
    required this.fps,
    required this.cues,
  });

  Map<String, dynamic> toJson() {
    return {
      "fps": fps,
      "cues": cues
          .map((cue) => cue.toJson())
          .toList(),
    };
  }

  static TempoProject fromJson(
    Map<String, dynamic> json,
  ) {
    return TempoProject(
      fps: (json["fps"] as num).toDouble(),

      cues: (json["cues"] as List)
          .map((cue) => Cue.fromJson(cue))
          .toList(),
    );
  }
}