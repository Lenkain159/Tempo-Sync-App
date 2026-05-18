class HitPoint 
{
  String name;
  String time; // formato SMPTE por ahora como texto

  bool hasSubdivisionChange;
  int? subdivision;

  bool isDialogueStart;
  bool isDialogueEnd;

  HitPoint
  (
    {
    required this.name,
    required this.time,
    this.hasSubdivisionChange = false,
    this.subdivision,
    this.isDialogueStart = false,
    this.isDialogueEnd = false,
    }
  );
}