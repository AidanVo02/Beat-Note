import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/idea.dart';

class AppStorage {
  AppStorage();

  static const _fileName = 'beatnote_data.json';
  static const _tmpFileName = 'beatnote_data.json.tmp';

  Future<List<Idea>> loadIdeas() async {
    try {
      final file = await _dataFile();
      if (!await file.exists()) return const [];
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const [];
      final ideas = decoded['ideas'];
      if (ideas is! List) return const [];
      return ideas
          .whereType<Map>()
          .map((m) => Idea.fromJson(m.cast<String, Object?>()))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveIdeas(List<Idea> ideas) async {
    final file = await _dataFile();
    final tmp = await _tmpDataFile();
    final payload = <String, Object?>{
      'schemaVersion': 1,
      'ideas': ideas.map((i) => i.toJson()).toList(growable: false),
      'savedAt': DateTime.now().toIso8601String(),
    };
    // Atomic write: write to temp file then rename, to avoid corrupting the
    // main JSON file if the app is killed during write.
    await tmp.writeAsString(jsonEncode(payload), flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await tmp.rename(file.path);
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_fileName');
  }

  Future<File> _tmpDataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_tmpFileName');
  }
}
