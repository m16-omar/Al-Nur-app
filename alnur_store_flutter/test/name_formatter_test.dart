import 'package:flutter_test/flutter_test.dart';
import 'package:alnur_store_flutter/core/utils/name_formatter.dart';

void main() {
  group('NameFormatter Unit Tests', () {
    test('extracts clean first name from email usernames with numbers', () {
      expect(NameFormatter.formatFirstName('uabdullahi676@gmail.com'), equals('Abdullahi'));
      expect(NameFormatter.formatFirstName('Uabdullahi676'), equals('Abdullahi'));
      expect(NameFormatter.formatFirstName('uabdullahi'), equals('Abdullahi'));
    });

    test('extracts clean first name from dots and full names', () {
      expect(NameFormatter.formatFirstName('abdullahi.usman@gmail.com'), equals('Abdullahi'));
      expect(NameFormatter.formatFirstName('Aisha Mohammed'), equals('Aisha'));
      expect(NameFormatter.formatFirstName('Fatima Zahra'), equals('Fatima'));
    });

    test('handles single Islamic names and fallbacks gracefully', () {
      expect(NameFormatter.formatFirstName('Fatima'), equals('Fatima'));
      expect(NameFormatter.formatFirstName('khadija99'), equals('Khadija'));
      expect(NameFormatter.formatFirstName('guest'), equals('Valued Patron'));
      expect(NameFormatter.formatFirstName(null), equals('Valued Patron'));
      expect(NameFormatter.formatFirstName(''), equals('Valued Patron'));
    });
  });
}

