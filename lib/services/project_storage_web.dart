import 'package:file_picker/file_picker.dart';
import 'project_storage.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class ProjectStorageWeb
    extends ProjectStorage {

  @override
  Future<void> writeText(
    String text,
  ) async {

    final bytes = utf8.encode(text);

    final blob = html.Blob([bytes]);

    final url =
        html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..download = "Proyecto Tempo Sync.tsync"
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  @override
  Future<String?> readText() async {

    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["tsync"],
      withData: true,
    );

    if (result == null) {
      return null;
    }

    final bytes = result.files.single.bytes;

    if (bytes == null) {
      return null;
    }

    return utf8.decode(bytes);
  }

}