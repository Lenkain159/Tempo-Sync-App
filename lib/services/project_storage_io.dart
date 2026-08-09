import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'project_storage.dart';

class ProjectStorageIO
    extends ProjectStorage {

  @override
  Future<void> writeText(
    String text,
  ) async {

    final String? path =
        await FilePicker.platform.saveFile(
      dialogTitle: "Guardar proyecto",
      fileName: "Proyecto Tempo Sync.tsync",
    );

    if (path == null) {
      return;
    }

    String finalPath = path;

    if (!finalPath.toLowerCase().endsWith(".tsync")) {
      finalPath += ".tsync";
    }

    await File(finalPath).writeAsString(text);
  }

  @override
  Future<String?> readText() async {

    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["tsync"],
    );

    if (result == null) {
      return null;
    }

    final file =
        File(result.files.single.path!);

    return await file.readAsString();
  }

}