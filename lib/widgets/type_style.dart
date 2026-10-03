// LỚP WIDGETS – màu sắc và biểu tượng cho từng loại tài liệu.

import 'package:flutter/material.dart';

import '../database/tables.dart';

class TypeStyle {
  const TypeStyle(this.icon, this.color);

  final IconData icon;
  final Color color;

  static TypeStyle of(DocType type) => switch (type) {
        DocType.lecture => const TypeStyle(Icons.menu_book, Colors.indigo),
        DocType.exercise => const TypeStyle(Icons.edit_note, Colors.orange),
        DocType.reference => const TypeStyle(Icons.library_books, Colors.teal),
      };
}
