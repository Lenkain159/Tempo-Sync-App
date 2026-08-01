class MusicalPosition {
  final int bar;
  final int beat;
  final int subdivision;

  final double frameError;
  final double millisecondsError;

  const MusicalPosition({
    required this.bar,
    required this.beat,
    required this.subdivision,
    required this.frameError,
    required this.millisecondsError,
  });
}