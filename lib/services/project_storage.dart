import 'dart:convert';

import '../models/tempo_project.dart';

abstract class ProjectStorage {

  Future<void> writeText(
    String text,
  );

  Future<String?> readText();

  Future<void> save(
    TempoProject project,
  ) async {

    final json = const JsonEncoder.withIndent("  ")
        .convert(project.toJson());

    await writeText(json);

  }

  Future<TempoProject?> load() async {

    final json = await readText();

    if (json == null) {
      return null;
    }

    return TempoProject.fromJson(
      jsonDecode(json),
    );
  }
}