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
}