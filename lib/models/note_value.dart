class NoteValue {
  final String name;
  final double value;
  final String image;

  const NoteValue({
    required this.name,
    required this.value,
    required this.image,
  });
}

const noteValues = [

  NoteValue(
    name: "Redonda",
    value: 1,
    image: "assets/notes/whole.png",
  ),

  NoteValue(
    name: "Blanca",
    value: 0.5,
    image: "assets/notes/half.png",
  ),

  NoteValue(
    name: "Negra",
    value: 0.25,
    image: "assets/notes/quarter.png",
  ),

  NoteValue(
    name: "Corchea",
    value: 0.125,
    image: "assets/notes/eighth.png",
  ),

  NoteValue(
    name: "Semicorchea",
    value: 0.0625,
    image: "assets/notes/sixteenth.png",
  ),
];