import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/idea.dart';

class AppStorage {
  AppStorage();

  static const _fileName = 'beatnote_data.json';

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
    final payload = <String, Object?>{
      'schemaVersion': 1,
      'ideas': ideas.map((i) => i.toJson()).toList(growable: false),
      'savedAt': DateTime.now().toIso8601String(),
    };
    await file.writeAsString(jsonEncode(payload));
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_fileName');
  }
}

