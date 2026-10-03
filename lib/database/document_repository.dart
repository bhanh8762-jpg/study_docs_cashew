// LỚP DATABASE – giao diện truy cập dữ liệu (abstraction).
// Lớp STRUCT chỉ phụ thuộc vào giao diện này, không biết dữ liệu lưu ở đâu.

import 'tables.dart';

abstract class DocumentRepository {
  Future<StudyDocument> add(StudyDocument document);
  Future<StudyDocument> update(StudyDocument document);
  Future<bool> delete(int id);
  Future<StudyDocument?> get(int id);
  Future<List<StudyDocument>> getAll();

  Future<List<StudyDocument>> search(SearchCriteria criteria) async =>
      (await getAll()).where(criteria.accepts).toList();
}
