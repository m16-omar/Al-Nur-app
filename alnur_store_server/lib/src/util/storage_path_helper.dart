import 'dart:math';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

/// Helper utilities for storage file path sanitization and MIME type detection.
class StoragePathHelper {
  static final _random = Random();

  /// Normalizes and sanitizes a storage path, preventing path traversal.
  static String sanitizePath(String path) {
    var cleaned = path.trim().replaceAll('\\', '/');

    // Prevent directory traversal
    while (cleaned.contains('../')) {
      cleaned = cleaned.replaceAll('../', '');
    }
    while (cleaned.startsWith('/')) {
      cleaned = cleaned.substring(1);
    }
    while (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }

    // Collapse multiple consecutive slashes
    cleaned = cleaned.replaceAll(RegExp(r'/+'), '/');

    return cleaned.isEmpty ? 'unnamed_file' : cleaned;
  }

  /// Generates a structured unique path for uploads.
  /// Example: generatePath('products', 'gold_abaya.jpg') -> 'products/gold-abaya-173000000-a1b2.jpg'
  static String generatePath({
    required String folder,
    required String filename,
    String? slug,
  }) {
    final ext = p.extension(filename).toLowerCase();
    final nameWithoutExt = p.basenameWithoutExtension(filename);
    
    final base = (slug != null && slug.trim().isNotEmpty)
        ? slug.trim()
        : nameWithoutExt;

    final sanitizedBase = base
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _random.nextInt(0xFFFFF).toRadixString(16).padLeft(5, '0');

    final effectiveBase = sanitizedBase.isEmpty ? 'upload' : sanitizedBase;
    final cleanExt = ext.isNotEmpty ? ext : '.bin';

    final cleanFolder = sanitizePath(folder);
    return '$cleanFolder/$effectiveBase-$timestamp-$randomSuffix$cleanExt';
  }

  /// Strips optional Data URI header from base64 string, e.g. 'data:image/png;base64,...'
  static String stripBase64Header(String base64Data) {
    var data = base64Data.trim();
    final commaIndex = data.indexOf(',');
    if (commaIndex != -1 && data.substring(0, commaIndex).contains('base64')) {
      data = data.substring(commaIndex + 1);
    }
    // Remove whitespace and line breaks
    return data.replaceAll(RegExp(r'\s+'), '');
  }

  /// Resolves the MIME type from a file name or path.
  static String resolveMimeType(String pathOrFilename) {
    return lookupMimeType(pathOrFilename) ?? 'application/octet-stream';
  }
}

