import 'package:flutter/material.dart';

import '../../../core/models/idea.dart';
import '../../../core/models/recording.dart';
import '../idea_repository.dart';
import '../../recordings/audio_player_controller.dart';
import '../../recordings/audio_recorder_controller.dart';
import 'idea_editor_page.dart';

class IdeaDetailPage extends StatefulWidget {
  const IdeaDetailPage({
    super.key,
    required this.ideaId,
    required this.repo,
    this.startEditingNote = false,
  });

  final String ideaId;
  final IdeaRepository repo;
  final bool startEditingNote;

  @override
  State<IdeaDetailPage> createState() => _IdeaDetailPageState();
}

class _IdeaDetailPageState extends State<IdeaDetailPage> {
  Idea? get _idea => widget.repo.getById(widget.ideaId);

  late final AudioRecorderController _recorder;
  late final AudioPlayerController _player;
  late final TextEditingController _noteController;
  bool _isEditingNote = false;
  bool _isRecording = false;
  String? _recordingPathInProgress;
  String? _playingRecordingId;

  @override
  // --- Screen lifecycle: init audio + note controllers ---
  void initState() {
    super.initState();
    _recorder = AudioRecorderController();
    _player = AudioPlayerController();
    _noteController = TextEditingController();
    _isEditingNote = widget.startEditingNote;
  }

  @override
  // --- Screen lifecycle: dispose controllers ---
  void dispose() {
    _noteController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  // --- UI: idea detail (metadata + notes + recordings) ---
  Widget build(BuildContext context) {
    final idea = _idea;
    if (idea == null) {
      return const Scaffold(body: Center(child: Text('Idea not found')));
    }

    if (!_isEditingNote) {
      final noteText = idea.note;
      if (_noteController.text != noteText) {
        _noteController.text = noteText;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(idea.title.isEmpty ? '(Untitled)' : idea.title),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (idea.musicKey != null)
                Chip(
                  avatar: const Icon(Icons.music_note_rounded, size: 18),
                  label: Text(idea.musicKey!),
                ),
              if (idea.bpm != null)
                Chip(
                  avatar: const Icon(Icons.speed_rounded, size: 18),
                  label: Text('${idea.bpm} BPM'),
                ),
              if (idea.mood != null)
                Chip(
                  avatar: const Icon(Icons.mood_rounded, size: 18),
                  label: Text(idea.mood!),
                ),
              for (final t in idea.tags) Chip(label: Text('#$t')),
            ],
          ),
          const SizedBox(height: 16),
          _NoteSection(
            isEditing: _isEditingNote,
            noteController: _noteController,
            onEditPressed: () => setState(() => _isEditingNote = true),
            onCancelPressed: () {
              _noteController.text = idea.note;
              setState(() => _isEditingNote = false);
            },
            onSavePressed: _saveNote,
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.graphic_eq_rounded),
              title: const Text('Voice memos'),
              subtitle: Text('${idea.recordings.length} recording(s)'),
              trailing: FilledButton.icon(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                label: Text(_isRecording ? 'Stop' : 'Record 10s'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (idea.recordings.isEmpty)
            Text(
              'No recordings yet. Tap "Record 10s" to capture a reference clip.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...idea.recordings.map((r) => _RecordingTile(
                  key: ValueKey(r.id),
                  recording: r,
                  isPlaying: _playingRecordingId == r.id,
                  onPlayPause: () => _togglePlay(r),
                  onRename: () => _renameRecording(r),
                )),
        ],
      ),
    );
  }

  Future<void> _edit() async {
    // --- Action: edit idea metadata (title/bpm/key/mood/tags) ---
    final idea = _idea;
    if (idea == null) return;

    final updated = await Navigator.of(context).push<Idea?>(
      MaterialPageRoute(builder: (_) => IdeaEditorPage(draft: idea)),
    );
    if (updated == null) return;

    widget.repo.upsert(updated);
    await widget.repo.save();
    setState(() {});
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    // --- Action: delete idea ---
    widget.repo.delete(widget.ideaId);
    await widget.repo.save();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _startRecording() async {
    // --- Action: start mic recording (reference capture) ---
    final idea = _idea;
    if (idea == null) return;

    final ok = await _recorder.hasPermission();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final path = await _recorder.startRecording(baseName: 'idea-${idea.id}');
    setState(() {
      _isRecording = true;
      _recordingPathInProgress = path;
    });

    // Auto stop after 10 seconds.
    // Future<void>.delayed(const Duration(seconds: 10), () async {
    //   if (!mounted) return;
    //   if (!await _recorder.isRecording()) return;
    //   await _stopRecording();
    // });
  }

  Future<void> _stopRecording() async {
    // --- Action: stop recording and attach to idea ---
    final idea = _idea;
    if (idea == null) return;

    final savedPath = await _recorder.stopRecording();
    final finalPath = savedPath ?? _recordingPathInProgress;

    setState(() {
      _isRecording = false;
      _recordingPathInProgress = null;
    });

    if (finalPath == null || finalPath.trim().isEmpty) return;

    final now = DateTime.now();
    final takeNumber = idea.recordings.length + 1;
    final rec = Recording(
      id: now.microsecondsSinceEpoch.toString(),
      title: 'Take $takeNumber',
      filePath: finalPath,
      createdAt: now,
    );

    final updated = idea.copyWith(
      recordings: [...idea.recordings, rec],
      updatedAt: now,
    );

    widget.repo.upsert(updated);
    await widget.repo.save();
    setState(() {});
  }

  Future<void> _togglePlay(Recording rec) async {
    // --- Action: play/pause a recording ---
    final isThisPlaying = _playingRecordingId == rec.id;
    if (isThisPlaying) {
      await _player.pause();
      setState(() => _playingRecordingId = null);
      return;
    }

    await _player.playFile(rec.filePath);
    setState(() => _playingRecordingId = rec.id);
  }

  Future<void> _renameRecording(Recording rec) async {
    // --- Action: rename recording (display title) ---
    final idea = _idea;
    if (idea == null) return;

    final controller = TextEditingController(text: rec.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename recording'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'e.g. Chorus hook take 1',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle == null) return;
    if (newTitle.isEmpty) return;

    final updatedRecs = idea.recordings
        .map((r) => r.id == rec.id ? r.copyWith(title: newTitle) : r)
        .toList(growable: false);

    final now = DateTime.now();
    final updatedIdea = idea.copyWith(recordings: updatedRecs, updatedAt: now);

    widget.repo.upsert(updatedIdea);
    if (!mounted) return;
    setState(() {});
    await widget.repo.save();
  }

  Future<void> _saveNote() async {
    // --- Action: save note from detail screen ---
    final idea = _idea;
    if (idea == null) return;

    final now = DateTime.now();
    final updated = idea.copyWith(
      note: _noteController.text.trim(),
      updatedAt: now,
    );

    widget.repo.upsert(updated);
    if (!mounted) return;
    setState(() => _isEditingNote = false);
    await widget.repo.save();
  }
}

class _NoteSection extends StatelessWidget {
  const _NoteSection({
    required this.isEditing,
    required this.noteController,
    required this.onEditPressed,
    required this.onCancelPressed,
    required this.onSavePressed,
  });

  final bool isEditing;
  final TextEditingController noteController;
  final VoidCallback onEditPressed;
  final VoidCallback onCancelPressed;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      final hasNote = noteController.text.trim().isNotEmpty;
      return Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: hasNote ? 'Edit note' : 'Add note',
                    onPressed: onEditPressed,
                    icon: Icon(hasNote ? Icons.edit_outlined : Icons.add_rounded),
                  ),
                ],
              ),
              if (!hasNote)
                Text(
                  'No notes yet. Tap + to add lyrics, chords, or structure.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                SelectableText(
                  noteController.text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Edit note', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(onPressed: onCancelPressed, child: const Text('Cancel')),
                FilledButton(onPressed: onSavePressed, child: const Text('Save')),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              autofocus: true,
              minLines: 6,
              maxLines: 14,
              decoration: const InputDecoration(
                hintText: 'Write lyrics, chords, structure, references...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingTile extends StatelessWidget {
  const _RecordingTile({
    super.key,
    required this.recording,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onRename,
  });

  final Recording recording;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
        title: Text(
          recording.title.trim().isEmpty ? 'Recording' : recording.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          _formatDate(recording.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          tooltip: 'Rename',
          onPressed: onRename,
          icon: const Icon(Icons.edit_outlined),
        ),
        onTap: onPlayPause,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}
 
