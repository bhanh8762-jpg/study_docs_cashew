// LỚP STRUCT – logic nghiệp vụ: Thêm / Sửa / Xóa / Tìm kiếm.
// Chỉ phụ thuộc vào lớp DATABASE thông qua giao diện DocumentRepository
// (repository cụ thể được tiêm vào từ main.dart).

import '../database/document_repository.dart';
import '../database/tables.dart';
import 'exceptions.dart';

const int maxTitleLength = 200;

class DocumentService {
  DocumentService(this._repo, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final DocumentRepository _repo;
  final DateTime Function() _now;

  // ---------------- Thêm ----------------
  Future<StudyDocument> addDocument({
    required String title,
    required DocType type,
    required String subject,
    String filePath = '',
    String description = '',
    Object tags = const <String>[],
  }) async {
    final now = _now();
    final doc = _validated(StudyDocument(
      title: title,
      type: type,
      subject: subject,
      filePath: filePath,
      description: description,
      tags: normalizeTags(tags),
      createdAt: now,
      updatedAt: now,
    ));
    await _ensureUnique(doc);
    return _repo.add(doc);
  }

  // ---------------- Sửa ----------------
  Future<StudyDocument> updateDocument(
    int id, {
    String? title,
    DocType? type,
    String? subject,
    String? filePath,
    String? description,
    Object? tags,
  }) async {
    final current = await getDocument(id);
    final updated = _validated(current.copyWith(
      title: title,
      type: type,
      subject: subject,
      filePath: filePath,
      description: description,
      tags: tags == null ? null : normalizeTags(tags),
      updatedAt: _now(),
    ));
    await _ensureUnique(updated);
    return _repo.update(updated);
  }

  // ---------------- Xóa ----------------
  Future<void> deleteDocument(int id) async {
    if (!await _repo.delete(id)) throw DocumentNotFoundException(id);
  }

  // ---------------- Đọc / Tìm kiếm ----------------
  Future<StudyDocument> getDocument(int id) async {
    final doc = await _repo.get(id);
    if (doc == null) throw DocumentNotFoundException(id);
    return doc;
  }

  Future<List<StudyDocument>> getAll() => _repo.getAll();

  Future<List<StudyDocument>> search({String keyword = '', DocType? type, String subject = '', String tag = ''}) =>
      _repo.search(SearchCriteria(
        keyword: keyword.trim(),
        type: type,
        subject: subject.trim(),
        tag: tag.trim().toLowerCase(),
      ));

  Future<Map<DocType, int>> statistics() async {
    final stats = {for (final t in DocType.values) t: 0};
    for (final d in await _repo.getAll()) {
      stats[d.type] = stats[d.type]! + 1;
    }
    return stats;
  }

  // ---------------- Quy tắc nghiệp vụ ----------------
  StudyDocument _validated(StudyDocument d) {
    final doc = d.copyWith(
      title: d.title.trim(),
      subject: d.subject.trim(),
      filePath: d.filePath.trim(),
      description: d.description.trim(),
    );
    if (doc.title.isEmpty) throw const ValidationException('Tiêu đề tài liệu không được để trống');
    if (doc.title.length > maxTitleLength) {
      throw const ValidationException('Tiêu đề không được dài quá $maxTitleLength ký tự');
    }
    if (doc.subject.isEmpty) throw const ValidationException('Môn học không được để trống');
    return doc;
  }

  /// Không cho phép hai tài liệu trùng tiêu đề trong cùng một môn học.
  Future<void> _ensureUnique(StudyDocument doc) async {
    for (final other in await _repo.search(SearchCriteria(subject: doc.subject))) {
      if (other.id != doc.id && other.title.toLowerCase() == doc.title.toLowerCase()) {
        throw DuplicateDocumentException(
            "Môn '${doc.subject}' đã có tài liệu tiêu đề '${doc.title}' (id=${other.id})");
      }
    }
  }
}

/// Chuẩn hóa thẻ: chữ thường, bỏ rỗng, bỏ trùng, giữ thứ tự.
/// Nhận vào chuỗi "a, b, c" hoặc danh sách.
List<String> normalizeTags(Object tags) {
  final source = tags is String ? tags.split(',') : (tags as Iterable).map((e) => '$e');
  final result = <String>[];
  for (final t in source) {
    final v = t.trim().toLowerCase();
    if (v.isNotEmpty && !result.contains(v)) result.add(v);
  }
  return result;
}
