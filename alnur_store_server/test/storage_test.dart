import 'dart:convert';
import 'package:alnur_store_server/src/util/cloudflare_r2_config.dart';
import 'package:alnur_store_server/src/util/storage_path_helper.dart';
import 'package:test/test.dart';

void main() {
  group('StoragePathHelper', () {
    test('sanitizePath removes leading/trailing slashes and path traversal attempts', () {
      expect(
        StoragePathHelper.sanitizePath('///products/summer/abaya.jpg///'),
        equals('products/summer/abaya.jpg'),
      );

      expect(
        StoragePathHelper.sanitizePath('../../etc/passwd'),
        equals('etc/passwd'),
      );

      expect(
        StoragePathHelper.sanitizePath(r'products\subfolder\image.png'),
        equals('products/subfolder/image.png'),
      );

      expect(
        StoragePathHelper.sanitizePath(''),
        equals('unnamed_file'),
      );
    });

    test('generatePath creates unique slugified paths with extensions', () {
      final path = StoragePathHelper.generatePath(
        folder: 'products',
        filename: 'Luxury Dubai Noir.JPEG',
        slug: 'luxury-dubai-noir',
      );

      expect(path, startsWith('products/luxury-dubai-noir-'));
      expect(path, endsWith('.jpeg'));
    });

    test('stripBase64Header cleanly strips data URI schemes', () {
      const rawData = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      const dataUri = 'data:image/png;base64,$rawData';

      expect(StoragePathHelper.stripBase64Header(dataUri), equals(rawData));
      expect(StoragePathHelper.stripBase64Header(rawData), equals(rawData));

      // Test decoding succeeds
      final bytes = base64.decode(StoragePathHelper.stripBase64Header(dataUri));
      expect(bytes.isNotEmpty, isTrue);
    });

    test('resolveMimeType detects correct MIME types', () {
      expect(StoragePathHelper.resolveMimeType('photo.jpg'), equals('image/jpeg'));
      expect(StoragePathHelper.resolveMimeType('photo.png'), equals('image/png'));
      expect(StoragePathHelper.resolveMimeType('photo.webp'), equals('image/webp'));
      expect(StoragePathHelper.resolveMimeType('document.pdf'), equals('application/pdf'));
      expect(StoragePathHelper.resolveMimeType('unknown.xyzabc'), equals('application/octet-stream'));
    });
  });

  group('CloudflareR2Setup', () {
    test('isConfigured is false by default when credentials are not supplied', () {
      expect(CloudflareR2Setup.isConfigured, isFalse);
    });
  });
}

