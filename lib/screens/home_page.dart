import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hit_point.dart';
import '../models/cue.dart';
import '../models/segment_result.dart';
import '../models/note_value.dart';
import '../models/meter_change.dart';
import '../models/musical_segment.dart';
import '../models/musical_position.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/tempo_project.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/project_storage.dart';
import '../services/storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final fpsController = TextEditingController();

  List<Cue> cues = [];

  void addCue() {
    setState(() {
      cues.add(
        Cue(
          name: "Cue ${cues.length + 1}",
          bpmMin: 80,
          bpmMax: 120,
          beat: noteValues[4], // Negra
          beatsPerBar: 4,
          subdivision: noteValues[5], // Corchea
          hitPoints: [],
        ),
      );
    });
  }

  bool isValidSubdivision(
    NoteValue beat,
    NoteValue subdivision,
  ) {

    // Caso especial
    if (beat.name == "Semicorchea") {
      return subdivision.name == "Semicorchea";
    }

    if (subdivision.value >= beat.value) {
      return false;
    }

    // Excepcion musical
    // Blanca con puntillo no permite negras con puntillo
    if (beat.name == "Blanca con puntillo" &&
        subdivision.name == "Negra con puntillo") {
      return false;
    }

    double ratio = beat.value / subdivision.value;

    return (ratio - ratio.round()).abs() < 0.0001;
  }

  String getMeterText(
  int beatsPerBar,
  NoteValue beat,
  ) {

    switch (beat.name) {

      case "Blanca con puntillo":
        return "${beatsPerBar * 3}/4";

      case "Negra con puntillo":
        return "${beatsPerBar * 3}/8";

      default:
        return "$beatsPerBar/${(1 / beat.value).round()}";
    }
  }

  Color? noteImageColor(BuildContext context) {

    switch (currentTheme.value) {

      case TempoTheme.light:
        return Colors.black;

      case TempoTheme.dark:
        return Colors.white;

      case TempoTheme.highContrast:
        return Colors.white;

    }
  }
  List<SegmentResult> results = [];

  final ProjectStorage storage = createStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScoreTempo'),

        actions: [

        PopupMenuButton<TempoTheme>(

          icon: const Icon(Icons.settings),

          onSelected: (theme) {
            currentTheme.value = theme;
          },

          itemBuilder: (context) => [

            const PopupMenuItem(
              value: TempoTheme.light,
              child: Text("Modo claro"),
            ),

            const PopupMenuItem(
              value: TempoTheme.dark,
              child: Text("Modo oscuro"),
            ),

            const PopupMenuItem(
              value: TempoTheme.highContrast,
              child: Text("Alto contraste"),
            ),

          ],
        ),

      ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // PANEL IZQUIERDO (INPUTS + HIT POINTS)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: loadProject,
                          icon: const Icon(Icons.folder_open),
                          label: const Text("Abrir"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: saveProject,
                          icon: const Icon(Icons.save),
                          label: const Text("Guardar"),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 15),
                  // INPUTS
                  TextField(
                    controller: fpsController,
                    decoration: const InputDecoration(labelText: 'FPS'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'),),
                    ],
                  ),

                  const SizedBox(height: 10),
                  
                  ElevatedButton(
                    onPressed: addCue,
                    child: const Text("Añadir Cue"),
                  ),

                  const SizedBox(height: 10),

                  // LISTA DE HIT POINTS
                  Expanded(
                    child: ListView.builder(
                      itemCount: cues.length,
                      itemBuilder: (context, cueIndex) {
                        final cue = cues[cueIndex];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // HEADER CUE
                                InkWell(
                                  onTap: () => editCue(cueIndex),

                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      //INFO DEL CUE
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cue.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          Text(
                                            "${cue.bpmMin} - ${cue.bpmMax} BPM",
                                          ),
                                        ],
                                      ),

                                      // BOTON ELIMINAR CUE
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),

                                        onPressed: () {
                                          setState(() {
                                            cues.removeAt(cueIndex);
                                            results.clear();
                                          });
                                        },
                                      )  
                                    ],
                                  ),
                                ),
                                                          
                                const SizedBox(height: 10),

                                // BOTÓN ADD HIT POINT
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      cue.hitPoints.add(
                                        HitPoint(
                                          name:
                                              "HP ${cue.hitPoints.length + 1}",
                                          time: "00:00:00:00",
                                        ),
                                      );

                                      sortHitPoints(cue);
                                    });
                                  },
                                  child:
                                      const Text("Añadir Hit Point"),
                                ),

                                const SizedBox(height: 10),

                                // HIT POINTS DEL CUE
                                Column(
                                  children: cue.hitPoints
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int hpIndex = entry.key;
                                    HitPoint hp = entry.value;

                                    return ListTile(
                                      leading: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          cue.hitPoints.removeAt(hpIndex);
                                        });
                                      },
                                    ),
                                      title: Text(
                                        "${hpIndex + 1}. ${hp.name}",
                                      ),

                                      subtitle: Text(hp.time),

                                      onTap: () => editHitPoint(
                                        cueIndex,
                                        hpIndex,
                                      ),

                                      trailing: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          if (hp.hasSubdivisionChange)
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(
                                                      left: 6),
                                              child: Icon(
                                                Icons.grid_view,
                                                color: Colors.green,
                                              ),
                                            ),
                                        ],
                                      ),   
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  ElevatedButton(
                    onPressed: calculateSegments,
                    child: const Text("Calcular"),
                  ),

                ],
              ),
            ),

            const SizedBox(width: 16),

            // PANEL DERECHO (RESULTADOS)
            Expanded(
              flex: 3,
              child: ListView(
                children: [

                  // BPM ÓPTIMO
                  for (final cue in cues) ...(() {

                    final cueSegments = buildSegments(cue);

                    return [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Text(
                              cue.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 20),

                            SvgPicture.asset(
                              cue.beat.image,
                              width: 32,
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                noteImageColor(context) ?? Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "= ${cue.optimalBpm.toStringAsFixed(0)} BPM",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),

                      for (int segmentIndex = 0; segmentIndex < cueSegments.length; segmentIndex++) ...(() {

                        final segment = cueSegments[segmentIndex];

                        return [

                          if (segmentIndex > 0)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 8,
                              ),
                              child: Column(
                                children: [

                                  const Divider(),

                                  Text(
                                    "Cambio de métrica en compás ${segment.firstBar}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                      fontSize: 17,
                                    ),
                                  ),

                                  const Divider(),
                                ],
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                            child: Row(
                              children: [

                                SvgPicture.asset(
                                  segment.beat.image,
                                  width: 26,
                                  colorFilter: ColorFilter.mode(
                                    noteImageColor(context) ?? Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  "= ${segment.bpm.toStringAsFixed(0)} BPM",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(width: 20),

                                Text(
                                  getMeterText(segment.beatsPerBar, segment.beat),
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: DataTable(

                              columns: [

                                DataColumn(
                                  label: Text("Hit Point"),
                                ),

                                DataColumn(
                                  label: Text("SMPTE"),
                                ),

                                DataColumn(
                                  label: Text("Compás"),
                                ),

                                DataColumn(
                                  label: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        segment.beat.image,
                                        width: 22,
                                        colorFilter: ColorFilter.mode(
                                          noteImageColor(context) ?? Colors.black,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      Text(segment.beat.name),
                                    ],
                                  ),
                                ),

                                DataColumn(
                                  label: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        segment.subdivision.image,
                                        width: 22,
                                        colorFilter: ColorFilter.mode(
                                          noteImageColor(context) ?? Colors.black,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      Text(segment.subdivision.name),
                                    ],
                                  ),
                                ),

                                DataColumn(
                                  label: Text("Frames"),
                                ),

                                DataColumn(
                                  label: Text("Milisegundos (ms)"),
                                ),
                              ],

                              rows: results
                                  .where((r) => r.cueName == cue.name && r.segmentIndex == segmentIndex)
                                  .map((result) {

                                Color rowColor;

                                switch (result.status) {

                                  case "OK":
                                    rowColor = Colors.green.shade100;
                                    break;

                                  case "LEVE":
                                    rowColor = Colors.yellow.shade100;
                                    break;

                                  default:
                                    rowColor = Colors.red.shade100;
                                }

                                const resultTextStyle = TextStyle(
                                    color: Colors.black,
                                  );

                                return DataRow(
                                  color: WidgetStatePropertyAll(rowColor),

                                  cells: [

                                    DataCell(
                                      Text(result.hitName,
                                      style: resultTextStyle)
                                    ),

                                    DataCell(
                                      Text(result.smpte,
                                      style: resultTextStyle)
                                    ),

                                    DataCell(
                                      Text(result.bar.toString(),
                                      style: resultTextStyle)
                                    ),

                                    DataCell(
                                      Text(result.beat.toString(),
                                      style: resultTextStyle)
                                    ),

                                    DataCell(
                                      Text(result.subdivision.toString(),
                                      style: resultTextStyle)
                                    ),
                                    
                                    DataCell(
                                      Text(
                                        "${result.frameError >= 0 ? "+" : ""}${result.frameError.toStringAsFixed(2)}",
                                      style: resultTextStyle)
                                    ),
                                
                                    DataCell(
                                      Text(
                                        "${result.millisecondsError >= 0 ? "+" : ""}${result.millisecondsError.toStringAsFixed(2)}",
                                      style: resultTextStyle)
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ];
                      })(),
                      const SizedBox(height: 30),
                    ];       
                  })(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void editHitPoint(int cueIndex, int hpIndex) {
    final hp = cues[cueIndex].hitPoints[hpIndex];

    final nameController = TextEditingController(text: hp.name);
    final timeController = TextEditingController(text: hp.time);

    bool hasMeterChange = hp.hasMeterChange;
      MeterChange meter =
          hp.meterChange ??
          MeterChange(
            beat: cues[cueIndex].beat,
            subdivision: cues[cueIndex].subdivision,
            beatsPerBar: cues[cueIndex].beatsPerBar,
            beforeHit: true,
          );

      NoteValue selectedMeterBeat = meter.beat;

      NoteValue selectedMeterSubdivision = meter.subdivision;

      if (!isValidSubdivision(
          selectedMeterBeat,
          selectedMeterSubdivision,
      )) {
        selectedMeterSubdivision =
            noteValues.firstWhere(
          (note) => isValidSubdivision(
            selectedMeterBeat,
            note,
          ),
        );
      }

      int selectedBeatsPerBar = meter.beatsPerBar;

      bool beforeHit = meter.beforeHit;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Hit Point"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nombre",
                      ),
                    ),

                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: "Tiempo (HH:MM:SS:FF)",
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                    ),

                    const SizedBox(height: 10),

                    //Cambio de métrica

                    Row(
                      children: [
                        Checkbox(
                          value: hasMeterChange,
                          onChanged: (value) {
                            setStateDialog(() 
                              {
                                hasMeterChange = value!;
                              }
                            );
                          },  
                        ),
                        const Text("Cambio de métrica"),
                      ],
                    ),

                    if (hasMeterChange)
                      Column(
                        children: [
                          RadioListTile<bool>(
                            title: const Text("Antes del Hit Point"),
                            value: true,
                            groupValue: beforeHit,
                            onChanged: (value) {
                              setStateDialog(() {
                                beforeHit = value!;
                              });
                            },
                          ),

                          RadioListTile<bool>(
                            title: const Text("Después del Hit Point"),
                            value: false,
                            groupValue: beforeHit,
                            onChanged: (value) {
                              setStateDialog(() {
                                beforeHit = value!;
                              });
                            },
                          ),

                          //SELECTOR DE BEAT | BEATS POR COMPÁS
                          DropdownButtonFormField<NoteValue>(
                            value: selectedMeterBeat,
                            decoration: const InputDecoration(
                              labelText: "Beat",
                            ),
                            items: noteValues.map((note) {
                              return DropdownMenuItem(
                                value: note,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      note.image,
                                      width: 24,
                                      height: 24,
                                      colorFilter: ColorFilter.mode(
                                        noteImageColor(context) ?? Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(note.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedMeterBeat = value!;

                                if (!isValidSubdivision(
                                    selectedMeterBeat,
                                    selectedMeterSubdivision,
                                )) {
                                  selectedMeterSubdivision =
                                      noteValues.firstWhere(
                                    (note) => isValidSubdivision(
                                      selectedMeterBeat,
                                      note,
                                    ),
                                  );
                                }
                              });
                            },
                          ),

                          TextField(
                            decoration: const InputDecoration(
                              labelText: "Beats por compás",
                            ),
                            controller: TextEditingController(
                              text: selectedBeatsPerBar.toString(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              selectedBeatsPerBar =
                                  int.tryParse(value) ?? 4;
                            },
                          ),

                          //SELECTOR DE SUBDIVISIÓN
                          DropdownButtonFormField<NoteValue>(
                            value: selectedMeterSubdivision,
                            decoration: const InputDecoration(
                              labelText: "Subdivisión",
                            ),

                            items: noteValues
                              .where((note) => isValidSubdivision(selectedMeterBeat, note))
                                .map((note) {

                                  return DropdownMenuItem(
                                    value: note,
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          note.image,
                                          width: 24,
                                          height: 24,
                                          colorFilter: ColorFilter.mode(
                                            noteImageColor(context) ?? Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(note.name),
                                      ],
                                    ),
                                  );

                                }).toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedMeterSubdivision = value!;
                              });
                            },
                          ),
                        ],
                      )
                  ],
                ),
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  hp.name = nameController.text;
                  hp.time = timeController.text;
                  hp.hasMeterChange = hasMeterChange;

                  if (hasMeterChange) {

                    hp.meterChange = MeterChange(
                      beat: selectedMeterBeat,
                      subdivision: selectedMeterSubdivision,
                      beatsPerBar: selectedBeatsPerBar,
                      beforeHit: beforeHit,
                    );

                  } else {

                    hp.meterChange = null;

                  }
                  sortHitPoints(cues[cueIndex]);
                });

                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  int smpteToFrames(String smpte, double fps) {
    try {
      final parts = smpte.split(":");

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      int seconds = int.parse(parts[2]);
      int frames = int.parse(parts[3]);

      double totalFrames =
          (hours * 3600 * fps) +
          (minutes * 60 * fps) +
          (seconds * fps) +
          frames;
        return totalFrames.round();
    } 
    catch (e) {
        return 0;
    }
  }

  void sortHitPoints(Cue cue) {
    double fps = double.tryParse(fpsController.text) ?? 24.0;

    cue.hitPoints.sort((a, b) {
      int aFrames = smpteToFrames(a.time, fps);
      int bFrames = smpteToFrames(b.time, fps);
      return aFrames.compareTo(bFrames);
    });
  }

  void editCue(int cueIndex) {
    final cue = cues[cueIndex];

    final nameController =
        TextEditingController(text: cue.name);

    final bpmMinController =
      TextEditingController(
        text: cue.bpmMin.toString(),
      );

    final bpmMaxController =
      TextEditingController(
        text: cue.bpmMax.toString(),
      );

    final beatsPerBarController =
      TextEditingController(
        text: cue.beatsPerBar.toString(),
      );

    NoteValue selectedBeat = cue.beat;

    NoteValue selectedSubdivision = cue.subdivision;

    if (!isValidSubdivision(selectedBeat, selectedSubdivision)) {
      selectedSubdivision = noteValues.firstWhere(
        (note) => isValidSubdivision(selectedBeat, note),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Cue"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nombre del Cue",
                      ),
                    ),

                    DropdownButtonFormField<NoteValue>(
                      initialValue: selectedBeat,
                      decoration: const InputDecoration(
                        labelText: "Figura del beat",
                      ),
                      items: noteValues.map((note){
                        return DropdownMenuItem(
                          value: note,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                note.image,
                                width: 22,
                                height: 22,
                                colorFilter: ColorFilter.mode(
                                  noteImageColor(context) ?? Colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(note.name),
                            ],
                          )
                        );
                      }).toList(),

                      onChanged: (value){
                        setStateDialog((){
                          selectedBeat = value!;
                          if (!isValidSubdivision(selectedBeat, selectedSubdivision)) {
                            selectedSubdivision = noteValues.firstWhere(
                              (note) => isValidSubdivision(selectedBeat, note),
                            );
                          }
                        });
                      },
                    ),

                    TextField(
                      controller: bpmMinController,
                      decoration: const InputDecoration(
                        labelText: "BPM Mínimo",
                      ),
                      keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'),),
                      ],
                    ),

                    TextField(
                      controller: bpmMaxController,
                      decoration: const InputDecoration(
                        labelText: "BPM Máximo",
                      ),
                      keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'),),
                      ],
                    ),

                    TextField(
                      controller: beatsPerBarController,
                      decoration: const InputDecoration(
                       labelText: "Beats por compás",
                      ),
                      keyboardType:
                      TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),

                    DropdownButtonFormField<NoteValue>(
                      initialValue: selectedSubdivision,
                      decoration: const InputDecoration(
                        labelText: "Subdivisión",
                      ),
                      items: noteValues
                        .where((note) => isValidSubdivision(selectedBeat, note))
                        .map((note){
                          return DropdownMenuItem(
                            value: note,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  note.image,
                                  width: 22,
                                  height: 22,
                                  colorFilter: ColorFilter.mode(
                                    noteImageColor(context) ?? Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(note.name),
                              ],
                            )
                          );
                        }).toList(),
                      onChanged: (value){
                        setStateDialog((){
                          selectedSubdivision = value!;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  cue.name = nameController.text;

                  cue.beat = selectedBeat;

                  cue.bpmMin =
                    double.tryParse(
                      bpmMinController.text,
                    ) ??
                    80;

                  cue.bpmMax =
                    double.tryParse(
                      bpmMaxController.text,
                    ) ??
                    120;

                  cue.beatsPerBar =
                    int.tryParse(
                      beatsPerBarController.text,
                    ) ??
                    4;

                  cue.subdivision = selectedSubdivision;
                });
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );  
      },
    );
  }

  void calculateCueBpm(Cue cue) {

    double fps =
        double.tryParse(fpsController.text) ?? 24.0;
    
    List<MusicalSegment> segments = buildSegments(cue);

    double bestBpm = cue.bpmMin;
    double bestError = 999999;

    // ITERAR BPM
    for (
      double bpm = cue.bpmMin;
      bpm <= cue.bpmMax;
      bpm += 1
    ) {

      double totalError = 0;

      // evaluar TODOS los hitpoints
      for (var hp in cue.hitPoints) {
        
        int hpFrame = smpteToFrames(
          hp.time,
          fps,
        );

        MusicalSegment segment = segments.firstWhere(
          (s) =>
            hpFrame >= s.startFrame &&
            hpFrame < s.endFrame,
        );

        final position =
          calculateMusicalPosition(
            segment: segment,
            hpFrame: hpFrame,
            fps: fps,
            bpm: bpm,
          );
        
        totalError += position.frameError.abs();
      }

      // mejor BPM global
      if (totalError < bestError) {

        bestError = totalError;

        bestBpm = bpm;
      }
    }

    cue.optimalBpm = bestBpm;
  }

  
  List<MusicalSegment> buildSegments(Cue cue) {

    if (cue.hitPoints.isEmpty) {
      return [];
    } 

    double fps =
      double.tryParse(fpsController.text) ?? 24;

    List<MusicalSegment> segments = [];

    // Primer segmento
    segments.add(
      MusicalSegment(
        startFrame: smpteToFrames(
          cue.hitPoints.first.time,
          fps,
        ),
        endFrame: 999999999,
        beat: cue.beat,
        subdivision: cue.subdivision,
        beatsPerBar: cue.beatsPerBar,
        firstBar: 1,
        bpm: cue.optimalBpm,
      ),
    );

    for (var hp in cue.hitPoints) {
      if (!hp.hasMeterChange) {
        continue;
      }
      //NUEVO SEGMENTO
      int hpFrame = smpteToFrames(
        hp.time,
        fps,
      );
      
      MeterChange change = hp.meterChange!;

      final position =
        calculateMusicalPosition(
          segment: segments.last,
          hpFrame: hpFrame,
          fps: fps,
          bpm: cue.optimalBpm,
        );

      int firstBarOfNewSegment;

      if (change.beforeHit) {
        firstBarOfNewSegment = position.bar - 1;
      } else {

        firstBarOfNewSegment = position.bar + 1;
      }
      
      int startFrame =
        getBarStartFrame(
          segment: segments.last,
          bar: firstBarOfNewSegment,
          fps: fps,
        );

      segments.last.endFrame = startFrame;

      segments.add(
        MusicalSegment(
          startFrame: startFrame,
          endFrame: 999999999,
          beat: change.beat,
          subdivision: change.subdivision,
          beatsPerBar: change.beatsPerBar,
          firstBar: firstBarOfNewSegment,
          bpm: cue.optimalBpm,
        )
      );
    }

    segments.last.endFrame = 999999999;
    return segments;
  }
  
  MusicalPosition calculateMusicalPosition({
    required MusicalSegment segment,
    required int hpFrame,
    required double fps,
    required double bpm,
  }) {

    double beatDuration = 60 / bpm;

    double seconds = (hpFrame - segment.startFrame) / fps;

    double beatPosition = 1 + (seconds / beatDuration);

    double subdivisionsPerBeat = segment.beat.value / segment.subdivision.value;

    double subdivisionPosition = (beatPosition * subdivisionsPerBeat).roundToDouble() / subdivisionsPerBeat;

    int nearestBeat = subdivisionPosition.floor();

    int bar = ((nearestBeat - 1) ~/ segment.beatsPerBar) + segment.firstBar;

    int beat = ((nearestBeat - 1) % segment.beatsPerBar) + 1;

    double fractional = subdivisionPosition - subdivisionPosition.floor();

    int subdivisionPerBeatInt = subdivisionsPerBeat.round();

    int subdivision = (fractional * subdivisionPerBeatInt).floor() + 1;

    if (subdivision > subdivisionPerBeatInt) {
      subdivision = 1;
    }

    double beatOffset = beatPosition - subdivisionPosition;

    double errorSeconds = beatOffset * beatDuration;

    double errorFrames = errorSeconds * fps;

    return MusicalPosition(
      bar: bar,
      beat: beat,
      subdivision: subdivision,
      frameError: errorFrames,
      millisecondsError: errorSeconds * 1000,
    );
  }

  int getBarStartFrame({
    required MusicalSegment segment,
    required int bar,
    required double fps,
  }) {

    double beatDuration =
        60 / segment.bpm;

    int beatsFromSegmentStart =
        (bar - segment.firstBar) * segment.beatsPerBar;

    double seconds = 
        beatsFromSegmentStart * beatDuration;   

    return segment.startFrame +
        (seconds * fps).round();
  }


  void calculateSegments() {

    results.clear();
    double fps =
        double.tryParse(fpsController.text) ?? 24.0;
    for (var cue in cues) {
      // calcular BPM global del cue
      calculateCueBpm(cue);

      List<MusicalSegment> segments =
          buildSegments(cue);

      for (
        int i = 0;
        i < cue.hitPoints.length;
        i++
      ) 
      {        
        final hp = cue.hitPoints[i];

        int hpFrames =
          smpteToFrames(hp.time, fps);

        MusicalSegment segment = segments.firstWhere(
          (s) =>
            hpFrames >= s.startFrame &&
            hpFrames < s.endFrame,
        );

        int segmentIndex = segments.indexOf(segment);

        final position = calculateMusicalPosition(
          segment: segment,
          hpFrame: hpFrames,
          fps: fps,
          bpm: cue.optimalBpm,
        );

        results.add(
          SegmentResult(
            hitName: hp.name,
            smpte: hp.time,

            cueName: cue.name,
            segmentIndex: segmentIndex,
            bar: position.bar,
            beat: position.beat,
            subdivision: position.subdivision,
            frameError: position.frameError,
            millisecondsError: position.millisecondsError,

            status: position.frameError.abs() <= 3
                ? "OK"
                : position.frameError.abs() <= 6
                    ? "LEVE"
                    : "FUERA",
          ),
        );
      }
    }

    setState(() {});
  }

  Future<void> saveProject() async {

    final project = TempoProject(
      fps:
          double.tryParse(
            fpsController.text,
          ) ??
          24,
      cues: cues,
    );

    await storage.save(project);
  }

  Future<void> loadProject() async {

    final project =
        await storage.load();

    if (project == null) {
      return;
    }

    setState(() {

      fpsController.text =
          project.fps.toString();

      cues = project.cues;

    });

    calculateSegments();
  }
}

