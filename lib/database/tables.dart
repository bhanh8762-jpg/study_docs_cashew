// LỚP DATABASE – định nghĩa "bảng" dữ liệu (thực thể) của ứng dụng.
// Theo cách tổ chức của Cashew: lib/database/tables.dart chứa các mô hình dữ liệu.
// File này KHÔNG import bất kỳ lớp nào khác (struct, pages, widgets).

enum DocType {
  lecture('bai_giang', 'Bài giảng'),
  exercise('bai_tap', 'Bài tập'),
  reference('tham_khao', 'Tham khảo');

  const DocType(this.code, this.label);

  final String code;
  final String label;

  static DocType fromCode(String code) => DocType.values.firstWhere(
        (t) => t.code == code,
        orElse: () => throw ArgumentError('Loại tài liệu không hợp lệ: $code'),
      );
}

/// Thực thể Tài liệu học tập (bất biến).
class StudyDocument {
  const StudyDocument({
    this.id,
    required this.title,
    required this.type,
    required this.subject,
    this.filePath = '',
    this.description = '',
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final DocType type;
  final String subject;
  final String filePath;
  final String description;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyDocument copyWith({
    int? id,
    String? title,
    DocType? type,
    String? subject,
    String? filePath,
    String? description,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      filePath: filePath ?? this.filePath,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Tài liệu có chứa từ khóa không (không phân biệt hoa/thường, hỗ trợ tiếng Việt).
  bool matches(String keyword) {
    final kw = keyword.trim().toLowerCase();
    if (kw.isEmpty) return true;
    final haystack = [title, subject, description, ...tags].join(' ').toLowerCase();
    return haystack.contains(kw);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.code,
        'subject': subject,
        'filePath': filePath,
        'description': description,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory StudyDocument.fromJson(Map<String, dynamic> json) => StudyDocument(
        id: json['id'] as int?,
        title: json['title'] as String,
        type: DocType.fromCode(json['type'] as String),
        subject: json['subject'] as String,
        filePath: (json['filePath'] ?? '') as String,
        description: (json['description'] ?? '') as String,
        tags: List<String>.from((json['tags'] ?? const []) as List),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      other is StudyDocument && other.id == id && other.updatedAt == updatedAt && other.title == title;

  @override
  int get hashCode => Object.hash(id, title, updatedAt);
}

/// Tiêu chí tìm kiếm (tất cả đều tùy chọn).
class SearchCriteria {
  const SearchCriteria({this.keyword = '', this.type, this.subject = '', this.tag = ''});

  final String keyword;
  final DocType? type;
  final String subject;
  final String tag;

  bool accepts(StudyDocument d) {
    if (type != null && d.type != type) return false;
    if (subject.isNotEmpty && d.subject.toLowerCase() != subject.trim().toLowerCase()) return false;
    if (tag.isNotEmpty && !d.tags.contains(tag.trim().toLowerCase())) return false;
    return d.matches(keyword);
  }
}
