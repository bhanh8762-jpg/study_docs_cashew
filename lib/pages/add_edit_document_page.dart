// LỚP PAGES – màn hình Thêm / Sửa tài liệu.
// Chỉ thu thập dữ liệu nhập; việc kiểm tra quy tắc nghiệp vụ do lớp STRUCT đảm nhận.

import 'package:flutter/material.dart';

import '../database/tables.dart';
import '../struct/documents_controller.dart';
import '../struct/exceptions.dart';

class AddEditDocumentPage extends StatefulWidget {
  const AddEditDocumentPage({super.key, required this.controller, this.document});

  final DocumentsController controller;
  final StudyDocument? document;

  bool get isEditing => document != null;

  @override
  State<AddEditDocumentPage> createState() => _AddEditDocumentPageState();
}

class _AddEditDocumentPageState extends State<AddEditDocumentPage> {
  late final _title = TextEditingController(text: widget.document?.title);
  late final _subject = TextEditingController(text: widget.document?.subject);
  late final _filePath = TextEditingController(text: widget.document?.filePath);
  late final _description = TextEditingController(text: widget.document?.description);
  late final _tags = TextEditingController(text: widget.document?.tags.join(', '));
  late DocType _type = widget.document?.type ?? DocType.lecture;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_title, _subject, _filePath, _description, _tags]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final c = widget.controller;
      final StudyDocument doc;
      if (widget.isEditing) {
        doc = await c.update(widget.document!.id!,
            title: _title.text,
            type: _type,
            subject: _subject.text,
            filePath: _filePath.text,
            description: _description.text,
            tags: _tags.text);
      } else {
        doc = await c.add(
            title: _title.text,
            type: _type,
            subject: _subject.text,
            filePath: _filePath.text,
            description: _description.text,
            tags: _tags.text);
      }
      if (mounted) {
        Navigator.of(context).pop(widget.isEditing ? 'Đã cập nhật "${doc.title}"' : 'Đã thêm "${doc.title}"');
      }
    } on DocumentException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String key, TextEditingController c, String label, {int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        key: Key(key),
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Sửa tài liệu' : 'Thêm tài liệu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('titleField', _title, 'Tiêu đề *'),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SegmentedButton<DocType>(
              segments: [for (final t in DocType.values) ButtonSegment(value: t, label: Text(t.label))],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
          ),
          _field('subjectField', _subject, 'Môn học *'),
          _field('fileField', _filePath, 'Đường dẫn / link tài liệu'),
          _field('descField', _description, 'Mô tả', maxLines: 3),
          _field('tagsField', _tags, 'Thẻ', hint: 'Phân tách bằng dấu phẩy, ví dụ: sql, co-ban'),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, key: const Key('errorText'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          FilledButton.icon(
            key: const Key('saveButton'),
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            label: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
