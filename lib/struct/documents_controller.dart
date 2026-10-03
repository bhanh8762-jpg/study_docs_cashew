// LỚP STRUCT – trạng thái giao diện (state management) bằng ChangeNotifier.
// Lớp PAGES lắng nghe controller này; controller gọi DocumentService.

import 'package:flutter/foundation.dart';

import '../database/tables.dart';
import 'document_service.dart';

class DocumentsController extends ChangeNotifier {
  DocumentsController(this._service);

  final DocumentService _service;

  List<StudyDocument> _documents = [];
  String _keyword = '';
  DocType? _typeFilter;
  bool _loading = false;

  List<StudyDocument> get documents => List.unmodifiable(_documents);
  String get keyword => _keyword;
  DocType? get typeFilter => _typeFilter;
  bool get loading => _loading;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    _documents = await _service.search(keyword: _keyword, type: _typeFilter);
    _loading = false;
    notifyListeners();
  }

  Future<void> setKeyword(String value) {
    _keyword = value;
    return refresh();
  }

  Future<void> setTypeFilter(DocType? type) {
    _typeFilter = type;
    return refresh();
  }

  Future<StudyDocument> add({
    required String title,
    required DocType type,
    required String subject,
    String filePath = '',
    String description = '',
    String tags = '',
  }) async {
    final doc = await _service.addDocument(
        title: title, type: type, subject: subject, filePath: filePath, description: description, tags: tags);
    await refresh();
    return doc;
  }

  Future<StudyDocument> update(
    int id, {
    required String title,
    required DocType type,
    required String subject,
    String filePath = '',
    String description = '',
    String tags = '',
  }) async {
    final doc = await _service.updateDocument(id,
        title: title, type: type, subject: subject, filePath: filePath, description: description, tags: tags);
    await refresh();
    return doc;
  }

  Future<void> delete(int id) async {
    await _service.deleteDocument(id);
    await refresh();
  }

  Future<Map<DocType, int>> statistics() => _service.statistics();
}
