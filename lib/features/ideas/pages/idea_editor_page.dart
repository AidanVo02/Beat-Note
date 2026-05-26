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
  late final TextEditingController _bpm;
  late final TextEditingController _mood;
  late final TextEditingController _tags;
  String? _selectedKey;

  static const List<String> _musicKeys = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
    'Cm',
    'C#m',
    'Dm',
    'D#m',
    'Em',
    'Fm',
    'F#m',
    'Gm',
    'G#m',
    'Am',
    'A#m',
    'Bm',
  ];

  @override
  // --- Screen lifecycle: init controllers from draft ---
  void initState() {
    super.initState();
    _draft = widget.draft ?? _newDraft();
    _title = TextEditingController(text: _draft.title);
    _bpm = TextEditingController(text: _draft.bpm?.toString() ?? '');
    _mood = TextEditingController(text: _draft.mood ?? '');
    _tags = TextEditingController(text: _draft.tags.join(', '));
    _selectedKey = _draft.musicKey;
  }

  @override
  // --- Screen lifecycle: dispose controllers ---
  void dispose() {
    _title.dispose();
    _bpm.dispose();
    _mood.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  // --- UI: create/edit idea metadata ---
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
                child: DropdownMenu<String>(
                  label: const Text('Key'),
                  hintText: 'Select a key',
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: _selectedKey,
                  dropdownMenuEntries: _musicKeys
                      .map((k) => DropdownMenuEntry<String>(value: k, label: k))
                      .toList(growable: false),
                  onSelected: (v) => setState(() => _selectedKey = v),
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
    // --- Helper: create new empty draft idea ---
    final now = DateTime.now();
    return Idea(
      id: now.microsecondsSinceEpoch.toString(),
      title: '',
      note: '',
      bpm: null,
      musicKey: null,
      mood: null,
      tags: const [],
      recordings: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  void _save() {
    // --- Action: save idea metadata and return to previous screen ---
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
      note: _draft.note,
      bpm: bpm,
      musicKey: _selectedKey,
      mood: _mood.text.trim().isEmpty ? null : _mood.text.trim(),
      tags: tags,
      recordings: _draft.recordings,
      updatedAt: now,
    );

    Navigator.of(context).pop(idea);
  }
}
