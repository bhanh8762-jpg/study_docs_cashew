// LỚP PAGES – màn hình chính: danh sách, tìm kiếm, lọc, xóa tài liệu.
// Chỉ làm việc với DocumentsController (lớp STRUCT), không truy cập dữ liệu trực tiếp.

import 'package:flutter/material.dart';

import '../database/tables.dart';
import '../struct/documents_controller.dart';
import '../struct/exceptions.dart';
import '../widgets/document_tile.dart';
import '../widgets/type_filter_bar.dart';
import 'add_edit_document_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});

  final DocumentsController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DocumentsController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.refresh();
  }

  Future<void> _openEditor([StudyDocument? doc]) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => AddEditDocumentPage(controller: controller, document: doc)),
    );
    if (message != null && mounted) _showSnack(message);
  }

  Future<void> _confirmDelete(StudyDocument doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài liệu?'),
        content: Text('Bạn có chắc muốn xóa "${doc.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await controller.delete(doc.id!);
      _showSnack('Đã xóa "${doc.title}"');
    } on DocumentException catch (e) {
      _showSnack(e.message);
    }
  }

  Future<void> _showStats() async {
    final stats = await controller.statistics();
    if (!mounted) return;
    final total = stats.values.fold(0, (a, b) => a + b);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thống kê'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final e in stats.entries) Text('${e.key.label}: ${e.value}'),
            const Divider(),
            Text('Tổng: $total', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng'))],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài liệu học tập'),
        actions: [
          IconButton(tooltip: 'Thống kê', icon: const Icon(Icons.bar_chart), onPressed: _showStats),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final docs = controller.documents;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  key: const Key('searchField'),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Tìm theo tiêu đề, môn học, mô tả, thẻ...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.setKeyword,
                ),
              ),
              TypeFilterBar(selected: controller.typeFilter, onChanged: controller.setTypeFilter),
              const SizedBox(height: 8),
              Expanded(
                child: docs.isEmpty
                    ? Center(
                        child: Text(
                          controller.loading ? 'Đang tải...' : 'Chưa có tài liệu nào',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: docs.length,
                        itemBuilder: (_, i) => DocumentTile(
                          document: docs[i],
                          onTap: () => _openEditor(docs[i]),
                          onDelete: () => _confirmDelete(docs[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
