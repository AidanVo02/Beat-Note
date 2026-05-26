import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderController {
  AudioRecorderController() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<String> startRecording({
    required String baseName,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final recDir = Directory('${dir.path}${Platform.pathSeparator}recordings');
    if (!await recDir.exists()) {
      await recDir.create(recursive: true);
    }

    final path =
        '${recDir.path}${Platform.pathSeparator}$baseName-${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
        bitRate: 128000,
      ),
      path: path,
    );

    return path;
  }

  Future<String?> stopRecording() => _recorder.stop();

  Future<bool> isRecording() => _recorder.isRecording();

  Future<void> dispose() => _recorder.dispose();
}
