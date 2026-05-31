import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileSaver {
  Future<File> saveBytesToDownloads({
    required List<int> bytes,
    required String fileName,
  }) async {
    final directory = await _resolveDownloadsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<Directory> _resolveDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) {
        return downloads;
      }

      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return externalDir;
      }

      return getApplicationDocumentsDirectory();
    }

    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      return downloads;
    }

    return getApplicationDocumentsDirectory();
  }
}
