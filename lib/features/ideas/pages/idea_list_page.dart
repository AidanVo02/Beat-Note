import 'package:flutter/material.dart';

import '../../../core/models/idea.dart';
import '../idea_repository.dart';
import '../widgets/empty_state.dart';
import 'idea_detail_page.dart';
import 'idea_editor_page.dart';

class IdeaListPage extends StatefulWidget {
  const IdeaListPage({super.key});

  @override
  State<IdeaListPage> createState() => _IdeaListPageState();
}

class _IdeaListPageState extends State<IdeaListPage> {
  final IdeaRepository _repo = IdeaRepository();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ideas = _repo.search(_searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BeatNote'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search title, note, tags...',
              leading: const Icon(Icons.search),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ),
      body: ideas.isEmpty
          ? EmptyState(
              hasQuery: _searchController.text.trim().isNotEmpty,
              onCreatePressed: _createIdea,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemBuilder: (context, index) {
                final idea = ideas[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    title: Text(
                      idea.title.isEmpty ? '(Untitled)' : idea.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      idea.summaryLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openIdea(idea.id),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: ideas.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createIdea,
        tooltip: 'New idea',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _createIdea() async {
    final created = await Navigator.of(context).push<Idea?>(
      MaterialPageRoute(builder: (_) => const IdeaEditorPage()),
    );
    if (created == null) return;
    setState(() => _repo.upsert(created));
  }

  Future<void> _openIdea(String id) async {
    final idea = _repo.getById(id);
    if (idea == null) return;

    final updated = await Navigator.of(context).push<Idea?>(
      MaterialPageRoute(
        builder: (_) => IdeaDetailPage(ideaId: id, repo: _repo),
      ),
    );

    if (updated == null) return;
    setState(() => _repo.upsert(updated));
  }
}

