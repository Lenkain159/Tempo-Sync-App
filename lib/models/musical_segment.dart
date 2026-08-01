import 'note_value.dart';

class MusicalSegment {
  final int startFrame;
  int endFrame;

  final NoteValue beat;
  final NoteValue subdivision;
  final int beatsPerBar;

  int firstBar;

  final double bpm;

  MusicalSegment({
    required this.startFrame,
    required this.endFrame,
    required this.beat,
    required this.subdivision,
    required this.beatsPerBar,
    required this.firstBar,
    required this.bpm,
  });
}