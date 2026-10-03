// LỚP DATABASE – lưu trữ bền vững bằng shared_preferences (dạng JSON).
// Chạy được trên Windows, Web (Chrome) và Android. Muốn đổi sang SQLite/Drift
// (như app Cashew gốc) chỉ cần viết một class khác implement DocumentRepository.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'document_repository.dart';
import 'tables.dart';

class LocalDocumentRepository extends DocumentRepository {
  LocalDocumentRepository(this._prefs);

  static const _docsKey = 'study_documents';
  static const _nextIdKey = 'study_documents_next_id';

  final SharedPreferences _prefs;

  static Future<LocalDocumentRepository> create() async =>
      LocalDocumentRepository(await SharedPreferences.getInstance());

  List<StudyDocument> _readAll() {
    final raw = _prefs.getString(_docsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => StudyDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeAll(List<StudyDocument> docs) =>
      _prefs.setString(_docsKey, jsonEncode(docs.map((d) => d.toJson()).toList()));

  @override
  Future<StudyDocument> add(StudyDocument document) async {
    final id = _prefs.getInt(_nextIdKey) ?? 1;
    final saved = document.copyWith(id: id);
    await _writeAll([..._readAll(), saved]);
    await _prefs.setInt(_nextIdKey, id + 1);
    return saved;
  }

  @override
  Future<StudyDocument> update(StudyDocument document) async {
    await _writeAll([for (final d in _readAll()) d.id == document.id ? document : d]);
    return document;
  }

  @override
  Future<bool> delete(int id) async {
    final docs = _readAll();
    final before = docs.length;
    docs.removeWhere((d) => d.id == id);
    await _writeAll(docs);
    return docs.length < before;
  }

  @override
  Future<StudyDocument?> get(int id) async {
    for (final d in _readAll()) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  Future<List<StudyDocument>> getAll() async => _readAll()..sort((a, b) => a.id!.compareTo(b.id!));
}
