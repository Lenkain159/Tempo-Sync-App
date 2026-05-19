class SegmentResult {

  final String hitName;
  final String smpte;

  final String cueName;

  final int bar;
  final int beat;
  final int subdivision;

  final double frameError;
  final double millisecondsError;

  final String status;

  SegmentResult({
    required this.hitName,
    required this.smpte,
    required this.cueName,

    required this.bar,
    required this.beat,
    required this.subdivision,

    required this.frameError,
    required this.millisecondsError,

    required this.status,
  });
}