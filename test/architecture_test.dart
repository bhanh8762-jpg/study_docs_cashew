// Kiểm thử QUY TẮC PHÂN LỚP của kiến trúc Cashew.
// Đọc mã nguồn trong lib/ và kiểm tra mỗi lớp chỉ import các lớp được phép:
//   database -> (chỉ database)
//   struct   -> database, struct              (không dùng giao diện material)
//   widgets  -> database/tables.dart, widgets
//   pages    -> struct, widgets, pages, database/tables.dart (KHÔNG dùng repository)

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const layers = ['database', 'struct', 'widgets', 'pages'];

final allowedLayers = <String, Set<String>>{
  'database': {'database'},
  'struct': {'database', 'struct'},
  'widgets': {'database', 'widgets'},
  'pages': {'database', 'struct', 'widgets', 'pages'},
};

/// Từ lớp UI, chỉ được import file mô hình của lớp database.
const uiAllowedDatabaseFiles = {'database/tables.dart'};

final _importRe = RegExp(r'''^import\s+['"]([^'"]+)['"]''', multiLine: true);

/// Trả về danh sách đường dẫn (tính từ lib/) mà [file] import nội bộ.
List<String> internalImports(String layerDir, File file) {
  final result = <String>[];
  for (final m in _importRe.allMatches(file.readAsStringSync())) {
    final uri = m.group(1)!;
    if (uri.startsWith('package:study_docs_cashew/')) {
      result.add(uri.substring('package:study_docs_cashew/'.length));
    } else if (!uri.contains(':')) {
      // import tương đối: "../struct/x.dart" hoặc "x.dart"
      result.add(uri.startsWith('../') ? uri.substring(3) : '$layerDir/$uri');
    }
  }
  return result;
}

List<String> violations(String layer, File file) {
  final errors = <String>[];
  for (final path in internalImports(layer, file)) {
    final target = path.split('/').first;
    if (!allowedLayers[layer]!.contains(target)) {
      errors.add('$path (lớp $target bị cấm)');
    } else if ((layer == 'pages' || layer == 'widgets') &&
        target == 'database' &&
        !uiAllowedDatabaseFiles.contains(path)) {
      errors.add('$path (giao diện không được dùng repository trực tiếp)');
    }
  }
  return errors;
}

Iterable<File> dartFiles(String layer) =>
    Directory('lib/$layer').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

void main() {
  test('mọi thư mục lớp đều tồn tại', () {
    for (final l in layers) {
      expect(Directory('lib/$l').existsSync(), isTrue, reason: 'Thiếu lib/$l');
    }
  });

  for (final layer in layers) {
    test('lớp $layer chỉ import các lớp được phép', () {
      for (final f in dartFiles(layer)) {
        expect(violations(layer, f), isEmpty, reason: f.path);
      }
    });
  }

  test('lớp database và struct không chứa mã giao diện', () {
    for (final layer in ['database', 'struct']) {
      for (final f in dartFiles(layer)) {
        expect(f.readAsStringSync().contains('package:flutter/material.dart'), isFalse, reason: f.path);
      }
    }
  });

  test('bộ kiểm tra phát hiện được vi phạm', () {
    final dir = Directory.systemTemp.createTempSync('arch');
    final fake = File('${dir.path}${Platform.pathSeparator}pages${Platform.pathSeparator}bad.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync("import '../database/local_document_repository.dart';\n");
    expect(violations('pages', fake), isNotEmpty);
    dir.deleteSync(recursive: true);
  });
}
