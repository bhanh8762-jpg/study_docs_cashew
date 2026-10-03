// Kiểm thử lớp DATABASE – cùng một bộ "hợp đồng" (contract test) chạy cho cả hai
// hiện thực, chứng minh có thể thay thế nguồn dữ liệu mà các lớp trên không đổi.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_docs_cashew/database/document_repository.dart';
import 'package:study_docs_cashew/database/local_document_repository.dart';
import 'package:study_docs_cashew/database/memory_document_repository.dart';
import 'package:study_docs_cashew/database/tables.dart';

StudyDocument doc(String title, DocType type, String subject, [List<String> tags = const []]) {
  final now = DateTime(2026, 10, 3);
  return StudyDocument(title: title, type: type, subject: subject, tags: tags, createdAt: now, updatedAt: now);
}

void repositoryContract(String name, Future<DocumentRepository> Function() create) {
  group(name, () {
    late DocumentRepository repo;
    late StudyDocument a, b;

    setUp(() async {
      repo = await create();
      a = await repo.add(doc('Chương 1', DocType.lecture, 'CSDL', ['sql', 'co-ban']));
      b = await repo.add(doc('Bài tập Giải tích', DocType.exercise, 'Toán', ['tich-phan']));
    });

    test('thêm và lấy theo id', () async {
      expect(a.id, isNotNull);
      final got = await repo.get(a.id!);
      expect(got!.title, 'Chương 1');
      expect(got.tags, ['sql', 'co-ban']);
      expect(got.type, DocType.lecture);
    });

    test('id không tồn tại trả về null', () async {
      expect(await repo.get(999), isNull);
    });

    test('cập nhật', () async {
      await repo.update(a.copyWith(title: 'Chương 1 sửa'));
      expect((await repo.get(a.id!))!.title, 'Chương 1 sửa');
    });

    test('xóa', () async {
      expect(await repo.delete(a.id!), isTrue);
      expect(await repo.delete(a.id!), isFalse);
      expect((await repo.getAll()).map((d) => d.id), [b.id]);
    });

    test('tìm kiếm theo từ khóa, loại, môn, thẻ', () async {
      expect((await repo.search(const SearchCriteria(keyword: 'GIẢI TÍCH'))).map((d) => d.id), [b.id]);
      expect((await repo.search(const SearchCriteria(type: DocType.lecture))).length, 1);
      expect((await repo.search(const SearchCriteria(subject: 'csdl'))).length, 1);
      expect((await repo.search(const SearchCriteria(tag: 'sql'))).length, 1);
    });
  });
}

void main() {
  repositoryContract('MemoryDocumentRepository', () async => MemoryDocumentRepository());

  repositoryContract('LocalDocumentRepository', () async {
    SharedPreferences.setMockInitialValues({});
    return LocalDocumentRepository.create();
  });

  test('LocalDocumentRepository lưu bền giữa các lần mở', () async {
    SharedPreferences.setMockInitialValues({});
    final r1 = await LocalDocumentRepository.create();
    await r1.add(doc('Lưu bền', DocType.reference, 'Mạng'));
    final r2 = await LocalDocumentRepository.create();
    expect((await r2.getAll()).map((d) => d.title), ['Lưu bền']);
    final next = await r2.add(doc('Tiếp', DocType.reference, 'Mạng'));
    expect(next.id, 2);
  });

  test('StudyDocument chuyển đổi JSON hai chiều', () {
    final d = doc('JSON', DocType.exercise, 'Lập trình', ['dart']).copyWith(id: 7);
    final back = StudyDocument.fromJson(d.toJson());
    expect(back.toJson(), d.toJson());
  });
}
