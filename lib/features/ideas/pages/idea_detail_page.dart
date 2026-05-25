import 'package:flutter/material.dart';

import '../../../core/models/idea.dart';
import '../idea_repository.dart';
import 'idea_editor_page.dart';

class IdeaDetailPage extends StatefulWidget {
  const IdeaDetailPage({super.key, required this.ideaId, required this.repo});

  final String ideaId;
  final IdeaRepository repo;

  @override
  State<IdeaDetailPage> createState() => _IdeaDetailPageState();
}

class _IdeaDetailPageState extends State<IdeaDetailPage> {
  Idea? get _idea => widget.repo.getById(widget.ideaId);

  @override
  Widget build(BuildContext context) {
    final idea = _idea;
    if (idea == null) {
      return const Scaffold(body: Center(child: Text('Idea not found')));
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
          if (idea.note.isEmpty)
            Text(
              'No note yet. Tap Edit to add details.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            SelectableText(
              idea.note,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.graphic_eq_rounded),
              title: const Text('Voice memos'),
              subtitle: const Text('We will add recording & playback next.'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit() async {
    final idea = _idea;
    if (idea == null) return;

    final updated = await Navigator.of(context).push<Idea?>(
      MaterialPageRoute(builder: (_) => IdeaEditorPage(draft: idea)),
    );
    if (updated == null) return;

    widget.repo.upsert(updated);
    setState(() {});
    if (!mounted) return;
    Navigator.of(context).pop(updated);
  }

  void _delete() {
    widget.repo.delete(widget.ideaId);
    Navigator.of(context).pop<Idea?>(null);
  }
}

