// LỚP WIDGETS – thành phần giao diện tái sử dụng, chỉ hiển thị dữ liệu.

import 'package:flutter/material.dart';

import '../database/tables.dart';
import 'type_style.dart';

class DocumentTile extends StatelessWidget {
  const DocumentTile({super.key, required this.document, this.onTap, this.onDelete});

  final StudyDocument document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final style = TypeStyle.of(document.type);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: style.color.withValues(alpha: 0.15),
          child: Icon(style.icon, color: style.color),
        ),
        title: Text(document.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${document.type.label} · ${document.subject}'),
            if (document.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final tag in document.tags)
                      Chip(
                        label: Text('#$tag'),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Xóa',
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
