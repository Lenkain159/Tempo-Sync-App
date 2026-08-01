import 'meter_change.dart';

class HitPoint 
{
  String name;
  String time; // formato SMPTE por ahora como texto

  bool hasSubdivisionChange;
  int? subdivision;

  bool isDialogueStart;
  bool isDialogueEnd;

  bool hasMeterChange;
  MeterChange? meterChange;

  HitPoint
  (
    {
    required this.name,
    required this.time,
    this.hasSubdivisionChange = false,
    this.subdivision,
    this.isDialogueStart = false,
    this.isDialogueEnd = false,
    this.hasMeterChange = false,
    }
  );
}