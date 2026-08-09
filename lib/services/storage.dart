import 'package:flutter/foundation.dart';

import 'project_storage.dart';
import 'project_storage_io.dart';
import 'project_storage_web.dart';

ProjectStorage createStorage() {
  if (kIsWeb) {
    return ProjectStorageWeb();
  }

  return ProjectStorageIO();
}