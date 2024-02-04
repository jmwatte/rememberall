import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class Saver {
  Future<String?> pickSaveDirectory() async {
    try {
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      return directoryPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking save directory: $e');
      }
      return null;
    }
  }

  read(String filename) async {
    try {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/$filename');
      String text = await file.readAsString();
      if (kDebugMode) {
        print("in Saver Read file: $text");
      }
      return text;
    } catch (e) {
      if (kDebugMode) {
        print("in Saver Couldn't read file");
      }
    }
  }

  save(String filename, String data) async {
    String? seletedDirectory = await pickSaveDirectory();
    final file = File('$seletedDirectory.path}/$filename');
    file.createSync(recursive: true);
    await file.writeAsString(data);

/*     if (!await lyricsdirectory.exists()) {

      lyricsdirectory.create(recursive: true);
    } else {
      final file = File('${lyricsdirectory.path}/$filename');
      await file.writeAsString(data);
    }
  */
  }
}
