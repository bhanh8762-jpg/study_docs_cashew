// LỚP STRUCT – các lỗi nghiệp vụ.

class DocumentException implements Exception {
  const DocumentException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ValidationException extends DocumentException {
  const ValidationException(super.message);
}

class DocumentNotFoundException extends DocumentException {
  DocumentNotFoundException(int id) : super('Không tìm thấy tài liệu có id = $id');
}

class DuplicateDocumentException extends DocumentException {
  const DuplicateDocumentException(super.message);
}
