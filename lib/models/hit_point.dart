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
    this.meterChange,
    }
  );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "time": time,
      "hasMeterChange": hasMeterChange,
      "meterChange":
          meterChange?.toJson(),
    };
  }

  static HitPoint fromJson(
    Map<String, dynamic> json,
  ) {
    return HitPoint(
      name: json["name"],
      time: json["time"],
      hasMeterChange:
          json["hasMeterChange"] ?? false,
      meterChange:
          json["meterChange"] != null
              ? MeterChange.fromJson(
                  json["meterChange"],
                )
              : null,
    );
  }
}