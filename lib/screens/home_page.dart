import 'package:flutter/material.dart';
import '../models/hit_point.dart';
import '../models/cue.dart';
import '../models/segment_result.dart';

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
          beatValue: 4,
          beatsPerBar: 4,
          subdivision: 2,
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
              child: Container(
                color: Colors.grey.shade200,
                child: ListView.builder(
                  itemCount: results.length,

                  itemBuilder: (context, index) {
                    final result = results[index];

                  Color cardColor;

                  switch (result.status) {

                    case "OK":
                      cardColor = Colors.green.shade100;
                      break;

                    case "LEVE":
                      cardColor = Colors.yellow.shade100;
                      break;

                    default:
                      cardColor = Colors.red.shade100;
                  }

                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.all(8),

                      child: ListTile(
                        title: Text(
                          "${result.startName} → ${result.endName}",
                        ),

                        subtitle: Text(
                          "${result.frameDistance} frames\n"
                          "${result.seconds.toStringAsFixed(2)} segundos\n"
                          "BPM óptimo: ${result.bestBpm.toStringAsFixed(1)}\n"
                          "${result.totalBars.toStringAsFixed(2)} compases\n"
                          "Error: ${result.frameError.toStringAsFixed(2)} frames",
                        ),
                      ),
                    );
                  },
                ),
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
    final subdivisionController = TextEditingController(
      text: hp.subdivision?.toString() ?? "",
    );

    bool hasSubdivisionChange = hp.hasSubdivisionChange;

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
                    // CAMBIO SUBDIVISIÓN
                    Row(
                      children: [
                        Checkbox(
                          value: hasSubdivisionChange,
                          onChanged: (value) {
                            setStateDialog(() {
                              hasSubdivisionChange = value!;
                            });
                          },
                        ),
                        const Text("Cambio subdivisión"),
                      ],
                    ),

                    if (hasSubdivisionChange)
                      TextField(
                        controller: subdivisionController,
                        decoration: const InputDecoration(
                          labelText:
                              "Subdivisión",
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: false),
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
                  hp.name = nameController.text;
                  hp.time = timeController.text;
                  hp.hasSubdivisionChange =
                      hasSubdivisionChange;
           
                  // SUBDIVISIÓN
                  if (hasSubdivisionChange) {
                    hp.subdivision = int.tryParse(subdivisionController.text);
                  } else {
                    hp.subdivision = null;
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


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Cue"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nombre del Cue",
                  ),
                ),

                TextField(
                  controller: bpmMinController,
                  decoration: const InputDecoration(
                    labelText: "BPM Mínimo",
                  ),
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                ),

                TextField(
                  controller: bpmMaxController,
                  decoration: const InputDecoration(
                    labelText: "BPM Máximo",
                  ),
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
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
      ) {
        
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

        double nearestBeat =
            totalBeats.roundToDouble();

        int barNumber =
          ((nearestBeat - 1) ~/ cue.beatsPerBar) + 1;

        int beatInBar =
          ((nearestBeat - 1).toInt() % cue.beatsPerBar) + 1;

        //Error
        double errorBeats =
            (totalBeats - nearestBeat).abs();

        double errorSeconds =
            errorBeats * beatDuration;

        double errorFrames =
            errorSeconds * fps;

        String status;

        if (errorFrames <= 3) {
          status = "OK";
        }
        else if (errorFrames <= 6) {
          status = "LEVE";
        }
        else {
          status = "FUERA";
        }

        results.add(
          SegmentResult(
            startName: firstHit.name,
            endName: hp.name,

            frameDistance: hpFrames - firstFrames,
            seconds: seconds,

            bestBpm: cue.optimalBpm,

            totalBeats: totalBeats,
            totalBars: barNumber.toDouble(),

            frameError: errorFrames,
            status: status,

            barNumber: barNumber,
            beatInBar: beatInBar,
          ),
        );
      }
    }

    setState(() {});
  }
}

