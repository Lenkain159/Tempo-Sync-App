class SegmentResult {
  String startName;
  String endName;
  int frameDistance;
  double seconds;
  double bestBpm;
  double totalBeats;
  double totalBars;
  double frameError;
  String status;
  final int barNumber;
  final int beatInBar;


  SegmentResult({
    required this.startName,
    required this.endName,
    required this.frameDistance,
    required this.seconds,
    required this.bestBpm,
    required this.totalBars,
    required this.totalBeats,
    required this.frameError,
    required this.status,
    required this.barNumber,
    required this.beatInBar,
  });
}