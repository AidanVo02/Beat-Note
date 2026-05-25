import 'package:flutter/material.dart';

import '../../../core/models/idea.dart';

class IdeaEditorPage extends StatefulWidget {
  const IdeaEditorPage({super.key, this.draft});

  final Idea? draft;

  @override
  State<IdeaEditorPage> createState() => _IdeaEditorPageState();
}

class _IdeaEditorPageState extends State<IdeaEditorPage> {
  late final Idea _draft;
  late final TextEditingController _title;
  late final TextEditingController _note;
  late final TextEditingController _bpm;
  late final TextEditingController _key;
  late final TextEditingController _mood;
  late final TextEditingController _tags;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? _newDraft();
    _title = TextEditingController(text: _draft.title);
    _note = TextEditingController(text: _draft.note);
    _bpm = TextEditingController(text: _draft.bpm?.toString() ?? '');
    _key = TextEditingController(text: _draft.musicKey ?? '');
    _mood = TextEditingController(text: _draft.mood ?? '');
    _tags = TextEditingController(text: _draft.tags.join(', '));
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _bpm.dispose();
    _key.dispose();
    _mood.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.draft != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit idea' : 'New idea'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          TextField(
            controller: _title,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. chorus hook, bassline idea...',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            minLines: 6,
            maxLines: 14,
            decoration: const InputDecoration(
              labelText: 'Note',
              alignLabelWithHint: true,
              hintText: 'Write lyrics, chords, structure, references...',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bpm,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'BPM',
                    hintText: 'e.g. 128',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _key,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Key',
                    hintText: 'e.g. C#m',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _mood,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Mood',
                    hintText: 'e.g. Chill, Dark, Hype',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _tags,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'comma-separated, e.g. edm, drop, lyric',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mic_none_rounded),
              title: const Text('Voice memo (coming soon)'),
              subtitle: const Text('We will add recording & playback next.'),
              trailing: const Icon(Icons.lock_outline_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Idea _newDraft() {
    final now = DateTime.now();
    return Idea(
      id: now.microsecondsSinceEpoch.toString(),
      title: '',
      note: '',
      bpm: null,
      musicKey: null,
      mood: null,
      tags: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  void _save() {
    final bpm = int.tryParse(_bpm.text.trim());
    final now = DateTime.now();
    final tags = _tags.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final idea = _draft.copyWith(
      title: _title.text.trim(),
      note: _note.text.trim(),
      bpm: bpm,
      musicKey: _key.text.trim().isEmpty ? null : _key.text.trim(),
      mood: _mood.text.trim().isEmpty ? null : _mood.text.trim(),
      tags: tags,
      updatedAt: now,
    );

    Navigator.of(context).pop(idea);
  }
}

