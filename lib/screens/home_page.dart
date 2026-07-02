import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hit_point.dart';
import '../models/cue.dart';
import '../models/segment_result.dart';
import '../models/note_value.dart';

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
          beat: noteValues[2], // Negra
          beatsPerBar: 4,
          subdivision: noteValues[3], // Corchea
          hitPoints: [],
        ),
      );
    });
  }

  List<SegmentResult> results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tempo Sync Tool')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // PANEL IZQUIERDO (INPUTS + HIT POINTS)
            Expanded(
              flex: 2,
              child: Column(
                children: [
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

            // PANEL DERECHO (RESULTADOS - vacío por ahora)
            Expanded(
              flex: 3,
              child: ListView(
                children: [

                  // BPM ÓPTIMO
                  for (var cue in cues) ...[
                    Padding(
                      padding: const EdgeInsets.all(12),

                      child: Text(
                        "${cue.name} → BPM óptimo: ${cue.optimalBpm.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: DataTable(

                        columns: const [

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
                            label: Text("Beat"),
                          ),

                          DataColumn(
                            label: Text("División del beat"),
                          ),

                          DataColumn(
                            label: Text("Frames"),
                          ),

                          DataColumn(
                            label: Text("Milisegundos (ms)"),
                          ),
                        ],

                        rows: results
                            .where((r) => r.cueName == cue.name)
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

                          return DataRow(
                            color: WidgetStatePropertyAll(rowColor),

                            cells: [

                              DataCell(
                                Text(result.hitName),
                              ),

                              DataCell(
                                Text(result.smpte),
                              ),

                              DataCell(
                                Text(result.bar.toString()),
                              ),

                              DataCell(
                                Text(result.beat.toString()),
                              ),

                              DataCell(
                                Text(result.subdivision.toString()),
                              ),
                              
                              DataCell(
                                Text(
                                  "${result.frameError >= 0 ? "+" : ""}${result.frameError.toStringAsFixed(2)}",
                                ),
                              ),

                              DataCell(
                                Text(
                                  "${result.millisecondsError >= 0 ? "+" : ""}${result.millisecondsError.toStringAsFixed(2)}",
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
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
                          child: Text(note.name),
                        );
                      }).toList(),

                      onChanged: (value){
                        setStateDialog((){
                          selectedBeat = value!;
                          if (selectedSubdivision.value >= selectedBeat.value) {
                            selectedSubdivision = noteValues.firstWhere(
                              (note) => note.value < selectedBeat.value,
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
                        .where((note) => note.value < selectedBeat.value)
                        .map((note){
                          return DropdownMenuItem(
                            value: note,
                            child: Text(note.name),
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

    int baseFrames =
      smpteToFrames(
        cue.hitPoints.first.time,
        fps,
      );

    double bestBpm = cue.bpmMin;
    double bestError = 999999;

    // ITERAR BPM
    for (
      double bpm = cue.bpmMin;
      bpm <= cue.bpmMax;
      bpm += 1
    ) {

      double totalError = 0;

      double beatDuration =
          60 / bpm;

      // evaluar TODOS los hitpoints
      for (var hp in cue.hitPoints) {

        int frames =
            smpteToFrames(hp.time, fps) - baseFrames;

        double seconds =
            frames / fps;

        double totalBeats =
            1 + (seconds / beatDuration);

        double nearestBeat =
          totalBeats.roundToDouble();

        double errorBeats =
          (totalBeats - nearestBeat).abs();

        double errorSeconds =
          errorBeats *
          beatDuration;

        double errorFrames =
            errorSeconds * fps;

        totalError += errorFrames;
      }

      // mejor BPM global
      if (totalError < bestError) {

        bestError = totalError;

        bestBpm = bpm;
      }
    }

    cue.optimalBpm = bestBpm;
  }

  void calculateSegments() {

    results.clear();
    double fps =
        double.tryParse(fpsController.text) ?? 24.0;
    for (var cue in cues) {
      // calcular BPM global del cue
      calculateCueBpm(cue);
      double bpm = cue.optimalBpm;
      double beatDuration =
          60 / bpm;
      for (
        int i = 0;
        i < cue.hitPoints.length;
        i++
      ) 
      {        
        final firstHit = cue.hitPoints.first;
        final hp = cue.hitPoints[i];
        
        int firstFrames =
            smpteToFrames(firstHit.time, fps);

        double firstSeconds =
            firstFrames / fps;

        int hpFrames =
          smpteToFrames(hp.time, fps);

        double hpSeconds =
            hpFrames / fps;

        double seconds =
            hpSeconds - firstSeconds;

        // cálculo musical
        double totalBeats =
            1 + (seconds / beatDuration);

        double subdivisionsPerBeat =
          cue.beat.value /
          cue.subdivision.value;

        double nearestSubdivision =
          (totalBeats * subdivisionsPerBeat)
              .roundToDouble() /
          subdivisionsPerBeat;

        int nearestBeat = nearestSubdivision.floor();
        
        int barNumber =
          ((nearestBeat - 1) ~/ cue.beatsPerBar) + 1;

        int beatInBar =
          ((nearestBeat - 1) % cue.beatsPerBar) + 1;

        double fractional =
          nearestSubdivision -
          nearestSubdivision.floor();

        int subdivisionsPerBeatInt =
          (cue.beat.value / cue.subdivision.value).round();

        int subdivisionNumber =
            (fractional * subdivisionsPerBeatInt)
                .floor() + 1;

        if (subdivisionNumber > subdivisionsPerBeatInt) {
          subdivisionNumber = 1;
        }

        //Error
        double beatOffset =
          totalBeats - nearestSubdivision;

        double errorSeconds =
            beatOffset * beatDuration;

        double errorFrames =
            errorSeconds * fps;

        String status;

        if (errorFrames.abs() <= 3) {
          status = "OK";
        }
        else if (errorFrames.abs() <= 6) {
          status = "LEVE";
        }
        else {
          status = "FUERA";
        }

        results.add(
          SegmentResult(
            hitName: hp.name,
            smpte: hp.time,

            cueName: cue.name,
            bar: barNumber,
            beat: beatInBar,
            subdivision: subdivisionNumber,
            frameError: errorFrames,
            millisecondsError: errorSeconds * 1000,

            status: status,
          ),
        );
      }
    }

    setState(() {});
  }
}

