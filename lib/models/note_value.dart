class NoteValue {
  final String name;
  final double value;
  final String image;

  const NoteValue({
    required this.name,
    required this.value,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
    };
  }

  static NoteValue fromJson(Map<String, dynamic> json) {
    return noteValues.firstWhere(
      (note) => note.name == json["name"],
    );
  }
}

const noteValues = [

  NoteValue(
    name: "Redonda",
    value: 1,
    image: "assets/notes/whole.png",
  ),

  NoteValue(
    name: "Blanca con puntillo",
    value: 0.75,
    image: "assets/notes/dotted_half.png",
  ),

  NoteValue(
    name: "Blanca",
    value: 0.5,
    image: "assets/notes/half.png",
  ),

  NoteValue(
    name: "Negra con puntillo",
    value: 0.375,
    image: "assets/notes/dotted_quarter.png",
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

List<NoteValue> getAvailableSubdivisions(NoteValue beat) {
  return noteValues.where((note) {

    // Debe ser una figura menor
    if (note.value >= beat.value) {
      return false;
    }

    // Excepción musical
    if (beat.name == "Blanca con puntillo" &&
        note.name == "Negra con puntillo") {
      return false;
    }

    // Excepción musical
    if (beat.name == "Negra con puntillo" &&
        note.name == "Negra") {
      return false;
    }

    return true;

  }).toList();
}