// Kiểm thử lớp STRUCT (logic nghiệp vụ) với repository trong bộ nhớ và repository giả.

import 'package:flutter_test/flutter_test.dart';
import 'package:study_docs_cashew/database/document_repository.dart';
import 'package:study_docs_cashew/database/memory_document_repository.dart';
import 'package:study_docs_cashew/database/tables.dart';
import 'package:study_docs_cashew/struct/document_service.dart';
import 'package:study_docs_cashew/struct/exceptions.dart';

/// Repository giả ghi lại mọi lời gọi – chứng minh service chỉ dùng giao diện trừu tượng.
class SpyRepository extends MemoryDocumentRepository {
  final calls = <String>[];

  @override
  Future<StudyDocument> add(StudyDocument document) {
    calls.add('add');
    return super.add(document);
  }

  @override
  Future<List<StudyDocument>> search(SearchCriteria criteria) {
    calls.add('search');
    return super.search(criteria);
  }
}

void main() {
  late DocumentService service;
  late StudyDocument lecture, exercise, reference;

  setUp(() async {
    service = DocumentService(MemoryDocumentRepository());
    lecture = await service.addDocument(
        title: 'Chương 1: SQL', type: DocType.lecture, subject: 'CSDL', tags: 'SQL, co-ban, sql');
    exercise = await service.addDocument(title: 'Bài tập tuần 1', type: DocType.exercise, subject: 'CSDL', tags: 'sql');
    reference = await service.addDocument(
        title: 'Giáo trình Giải tích', type: DocType.reference, subject: 'Toán', description: 'Đạo hàm');
  });

  group('Thêm', () {
    test('gán id tăng dần và chuẩn hóa thẻ', () async {
      expect([lecture.id, exercise.id, reference.id], [1, 2, 3]);
      expect(lecture.tags, ['sql', 'co-ban']);
    });

    test('tự cắt khoảng trắng thừa', () async {
      final d = await service.addDocument(title: '  Đề cương  ', type: DocType.reference, subject: '  Mạng ');
      expect(d.title, 'Đề cương');
      expect(d.subject, 'Mạng');
    });

    test('từ chối tiêu đề rỗng, môn học rỗng, tiêu đề quá dài', () async {
      expect(() => service.addDocument(title: '  ', type: DocType.lecture, subject: 'CSDL'),
          throwsA(isA<ValidationException>()));
      expect(() => service.addDocument(title: 'A', type: DocType.lecture, subject: ''),
          throwsA(isA<ValidationException>()));
      expect(() => service.addDocument(title: 'x' * 201, type: DocType.lecture, subject: 'CSDL'),
          throwsA(isA<ValidationException>()));
    });

    test('từ chối trùng tiêu đề trong cùng môn (không phân biệt hoa thường)', () async {
      expect(() => service.addDocument(title: 'chương 1: sql', type: DocType.exercise, subject: 'csdl'),
          throwsA(isA<DuplicateDocumentException>()));
    });

    test('cho phép trùng tiêu đề ở môn khác', () async {
      final d = await service.addDocument(title: 'Chương 1: SQL', type: DocType.lecture, subject: 'Hệ quản trị');
      expect(d.id, isNotNull);
    });
  });

  group('Sửa', () {
    test('cập nhật trường, giữ id và createdAt', () async {
      final u = await service.updateDocument(lecture.id!, title: 'Chương 1 (mới)', tags: 'sql, nang-cao');
      expect(u.id, lecture.id);
      expect(u.title, 'Chương 1 (mới)');
      expect(u.tags, ['sql', 'nang-cao']);
      expect(u.createdAt, lecture.createdAt);
      expect((await service.getDocument(lecture.id!)).title, 'Chương 1 (mới)');
    });

    test('cập nhật updatedAt theo đồng hồ', () async {
      final t = DateTime(2030, 1, 1);
      final s = DocumentService(MemoryDocumentRepository(), clock: () => t);
      final d = await s.addDocument(title: 'A', type: DocType.lecture, subject: 'B');
      expect(d.updatedAt, t);
    });

    test('báo lỗi khi sửa tài liệu không tồn tại', () {
      expect(() => service.updateDocument(999, title: 'x'), throwsA(isA<DocumentNotFoundException>()));
    });

    test('báo lỗi khi sửa thành tiêu đề trùng', () {
      expect(() => service.updateDocument(exercise.id!, title: 'Chương 1: SQL'),
          throwsA(isA<DuplicateDocumentException>()));
    });

    test('báo lỗi khi sửa thành tiêu đề rỗng', () {
      expect(() => service.updateDocument(exercise.id!, title: ''), throwsA(isA<ValidationException>()));
    });
  });

  group('Xóa', () {
    test('xóa thành công', () async {
      await service.deleteDocument(reference.id!);
      expect((await service.getAll()).length, 2);
      expect(() => service.getDocument(reference.id!), throwsA(isA<DocumentNotFoundException>()));
    });

    test('báo lỗi khi xóa id không tồn tại', () {
      expect(() => service.deleteDocument(999), throwsA(isA<DocumentNotFoundException>()));
    });
  });

  group('Tìm kiếm', () {
    test('theo từ khóa tiếng Việt có dấu', () async {
      expect((await service.search(keyword: 'ĐẠO HÀM')).map((d) => d.id), [reference.id]);
    });

    test('theo loại + môn học', () async {
      final r = await service.search(type: DocType.exercise, subject: 'csdl');
      expect(r.map((d) => d.id), [exercise.id]);
    });

    test('theo thẻ (khớp chính xác)', () async {
      expect((await service.search(tag: 'SQL')).length, 2);
      expect((await service.search(tag: 'co')).length, 0);
    });

    test('không có tiêu chí trả về tất cả', () async {
      expect((await service.search()).length, 3);
    });

    test('thống kê theo loại', () async {
      expect(await service.statistics(), {DocType.lecture: 1, DocType.exercise: 1, DocType.reference: 1});
    });
  });

  group('Tách biệt lớp', () {
    test('service chỉ giao tiếp qua DocumentRepository', () async {
      final spy = SpyRepository();
      final DocumentRepository asInterface = spy;
      await DocumentService(asInterface).addDocument(title: 'A', type: DocType.lecture, subject: 'B');
      expect(spy.calls, ['search', 'add']);
    });

    test('dữ liệu sai không bao giờ xuống tới repository', () async {
      final spy = SpyRepository();
      await expectLater(DocumentService(spy).addDocument(title: '', type: DocType.lecture, subject: 'B'),
          throwsA(isA<ValidationException>()));
      expect(spy.calls, isEmpty);
    });
  });
}
