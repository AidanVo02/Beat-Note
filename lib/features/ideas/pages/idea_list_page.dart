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
  final FocusNode _searchFocusNode = FocusNode();
  late final _LifecycleObserver _lifecycleObserver;

  @override
  // --- Screen lifecycle: load persisted ideas ---
  void initState() {
    super.initState();
    _lifecycleObserver = _LifecycleObserver(onPause: _repo.save);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _repo.load().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  // --- Screen lifecycle: dispose controllers ---
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  // --- UI: idea list + search ---
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
              focusNode: _searchFocusNode,
              autoFocus: false,
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
    // --- Navigate: create new idea ---
    _dismissKeyboard();
    final created = await Navigator.of(context).push<Idea?>(
      MaterialPageRoute(builder: (_) => const IdeaEditorPage()),
    );
    if (created == null) return;
    setState(() => _repo.upsert(created));
    await _repo.save();
  }

  Future<void> _openIdea(String id) async {
    // --- Navigate: open idea detail ---
    _dismissKeyboard();
    final idea = _repo.getById(id);
    if (idea == null) return;

    final changed = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(
        builder: (_) => IdeaDetailPage(ideaId: id, repo: _repo),
      ),
    );

    if (changed == true) {
      setState(() {});
    }
    _dismissKeyboard();
  }

  void _dismissKeyboard() {
    // --- UX helper: dismiss soft keyboard ---
    _searchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  _LifecycleObserver({required this.onPause});

  final Future<void> Function() onPause;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      onPause();
    }
  }
}
