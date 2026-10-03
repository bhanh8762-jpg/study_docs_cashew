// Kiểm thử lớp PAGES/WIDGETS – giao diện chạy với repository trong bộ nhớ,
// không cần lưu trữ thật. Kiểm tra luồng Thêm – Tìm kiếm – Sửa – Xóa trên UI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_docs_cashew/database/memory_document_repository.dart';
import 'package:study_docs_cashew/database/tables.dart';
import 'package:study_docs_cashew/main.dart';
import 'package:study_docs_cashew/struct/document_service.dart';
import 'package:study_docs_cashew/struct/documents_controller.dart';

Future<DocumentsController> pumpApp(WidgetTester tester) async {
  final controller = DocumentsController(DocumentService(MemoryDocumentRepository()));
  await tester.pumpWidget(StudyDocsApp(controller: controller));
  await tester.pumpAndSettle();
  return controller;
}

Future<void> addViaUi(WidgetTester tester, String title, String subject) async {
  await tester.tap(find.text('Thêm'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('titleField')), title);
  await tester.enterText(find.byKey(const Key('subjectField')), subject);
  await tester.tap(find.byKey(const Key('saveButton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('hiển thị trạng thái rỗng', (tester) async {
    await pumpApp(tester);
    expect(find.text('Chưa có tài liệu nào'), findsOneWidget);
  });

  testWidgets('thêm tài liệu qua form và hiển thị trong danh sách', (tester) async {
    await pumpApp(tester);
    await addViaUi(tester, 'Chương 1: SQL', 'CSDL');
    expect(find.text('Chương 1: SQL'), findsOneWidget);
    expect(find.text('Bài giảng · CSDL'), findsOneWidget);
  });

  testWidgets('hiển thị lỗi nghiệp vụ khi bỏ trống tiêu đề', (tester) async {
    await pumpApp(tester);
    await addViaUi(tester, '', 'CSDL');
    expect(find.byKey(const Key('errorText')), findsOneWidget);
    expect(find.text('Tiêu đề tài liệu không được để trống'), findsOneWidget);
  });

  testWidgets('tìm kiếm và lọc theo loại', (tester) async {
    final c = await pumpApp(tester);
    await c.add(title: 'Chương 1', type: DocType.lecture, subject: 'CSDL');
    await c.add(title: 'Giải tích', type: DocType.reference, subject: 'Toán');
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('searchField')), 'giải');
    await tester.pumpAndSettle();
    expect(find.text('Giải tích'), findsOneWidget);
    expect(find.text('Chương 1'), findsNothing);

    await tester.enterText(find.byKey(const Key('searchField')), '');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Bài giảng'));
    await tester.pumpAndSettle();
    expect(find.text('Chương 1'), findsOneWidget);
    expect(find.text('Giải tích'), findsNothing);
  });

  testWidgets('sửa tài liệu', (tester) async {
    final c = await pumpApp(tester);
    await c.add(title: 'Bản cũ', type: DocType.exercise, subject: 'Toán');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bản cũ'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('titleField')), 'Bản mới');
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();
    expect(find.text('Bản mới'), findsOneWidget);
    expect(find.text('Bản cũ'), findsNothing);
  });

  testWidgets('xóa tài liệu sau khi xác nhận', (tester) async {
    final c = await pumpApp(tester);
    await c.add(title: 'Sẽ bị xóa', type: DocType.reference, subject: 'Toán');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();
    expect(find.text('Sẽ bị xóa'), findsNothing);
    expect(c.documents, isEmpty);
  });
}
