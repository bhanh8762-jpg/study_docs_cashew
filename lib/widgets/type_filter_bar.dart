// LỚP WIDGETS – thanh lọc theo loại tài liệu.

import 'package:flutter/material.dart';

import '../database/tables.dart';

class TypeFilterBar extends StatelessWidget {
  const TypeFilterBar({super.key, required this.selected, required this.onChanged});

  final DocType? selected;
  final ValueChanged<DocType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ChoiceChip(label: const Text('Tất cả'), selected: selected == null, onSelected: (_) => onChanged(null)),
          for (final t in DocType.values)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(t.label),
                selected: selected == t,
                onSelected: (_) => onChanged(t),
              ),
            ),
        ],
      ),
    );
  }
}
