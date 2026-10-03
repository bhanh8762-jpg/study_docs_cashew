// LỚP DATABASE – lưu trữ trong bộ nhớ (dùng cho kiểm thử / demo).

import 'document_repository.dart';
import 'tables.dart';

class MemoryDocumentRepository extends DocumentRepository {
  final Map<int, StudyDocument> _items = {};
  int _nextId = 1;

  @override
  Future<StudyDocument> add(StudyDocument document) async {
    final saved = document.copyWith(id: _nextId++);
    _items[saved.id!] = saved;
    return saved;
  }

  @override
  Future<StudyDocument> update(StudyDocument document) async {
    _items[document.id!] = document;
    return document;
  }

  @override
  Future<bool> delete(int id) async => _items.remove(id) != null;

  @override
  Future<StudyDocument?> get(int id) async => _items[id];

  @override
  Future<List<StudyDocument>> getAll() async =>
      (_items.keys.toList()..sort()).map((k) => _items[k]!).toList();
}
