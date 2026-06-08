import 'dart:mirrors';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  test('print icons matching terms', () {
    final classMirror = reflectClass(HugeIcons);
    print('Matches:');
    classMirror.declarations.forEach((key, value) {
      final name = MirrorSystem.getName(key);
      final lower = name.toLowerCase();
      if (lower.contains('shield') ||
          lower.contains('hand') ||
          lower.contains('check') ||
          lower.contains('shake') ||
          lower.contains('award')) {
        print('FOUND_ICON: $name');
      }
    });
  });
}
