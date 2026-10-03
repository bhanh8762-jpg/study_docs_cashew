// Điểm khởi chạy – Composition Root.
// Nơi DUY NHẤT biết repository cụ thể: tạo LocalDocumentRepository (DATABASE),
// tiêm vào DocumentService và DocumentsController (STRUCT), rồi đưa cho HomePage (PAGES).

import 'package:flutter/material.dart';

import 'database/local_document_repository.dart';
import 'pages/home_page.dart';
import 'struct/document_service.dart';
import 'struct/documents_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await LocalDocumentRepository.create();
  final controller = DocumentsController(DocumentService(repository));
  runApp(StudyDocsApp(controller: controller));
}

class StudyDocsApp extends StatelessWidget {
  const StudyDocsApp({super.key, required this.controller});

  final DocumentsController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tài liệu học tập',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark, useMaterial3: true),
      home: HomePage(controller: controller),
    );
  }
}
