import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class Saver {
  read(String filename) async {
    try {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/$filename');
      String text = await file.readAsString();
      if (kDebugMode) {
        print(text);
      }
      return text;
    } catch (e) {
      if (kDebugMode) {
        print("Couldn't read file");
      }
    }
  }

  save(String filename, String data) async {
    data = data;
    filename = filename;
    final directory = await getExternalStorageDirectory();
    final poemsdirectory = Directory('${directory?.path}/lyrics');
    final file = File('${poemsdirectory.path}/$filename');
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
