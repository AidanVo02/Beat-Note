import '../../core/models/idea.dart';
import '../../core/storage/app_storage.dart';

class IdeaRepository {
  IdeaRepository({AppStorage? storage}) : _storage = storage ?? AppStorage();

  final List<Idea> _ideas = [];
  final AppStorage _storage;

  List<Idea> allNewestFirst() => List.unmodifiable(_ideas.reversed);

  List<Idea> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allNewestFirst();

    return _ideas
        .where((i) {
          final haystack = [
            i.title,
            i.note,
            i.musicKey ?? '',
            i.mood ?? '',
            i.tags.join(' '),
          ].join('\n').toLowerCase();
          return haystack.contains(q);
        })
        .toList()
        .reversed
        .toList(growable: false);
  }

  Idea? getById(String id) {
    for (final i in _ideas) {
      if (i.id == id) return i;
    }
    return null;
  }

  void upsert(Idea idea) {
    final index = _ideas.indexWhere((i) => i.id == idea.id);
    if (index == -1) {
      _ideas.add(idea);
      return;
    }
    _ideas[index] = idea;
  }

  void delete(String id) {
    _ideas.removeWhere((i) => i.id == id);
  }

  Future<void> load() async {
    _ideas
      ..clear()
      ..addAll(await _storage.loadIdeas());
  }

  Future<void> save() async {
    await _storage.saveIdeas(List.unmodifiable(_ideas));
  }
}
