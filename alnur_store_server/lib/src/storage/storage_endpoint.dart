import 'dart:convert';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../util/cloudflare_r2_config.dart';
import '../util/storage_path_helper.dart';

/// Endpoint for handling file and image uploads and storage backed by Cloudflare R2.
class StorageEndpoint extends Endpoint {
  /// Checks whether Cloudflare R2 cloud storage is actively connected.
  Future<bool> isCloudflareConfigured(Session session) async {
    return CloudflareR2Setup.isConfigured;
  }

  /// Creates a pre-signed direct upload description for client-to-Cloudflare direct upload.
  /// Returns a JSON description containing the PUT URL and required headers.
  Future<String?> getDirectUploadDescription(
    Session session, {
    required String path,
    String? storageId,
    int? maxFileSize,
  }) async {
    final sanitizedPath = StoragePathHelper.sanitizePath(path);
    final targetStorage = storageId ?? 'public';
    return await session.storage.createDirectFileUploadDescription(
      storageId: targetStorage,
      path: sanitizedPath,
      maxFileSize: maxFileSize ?? 20 * 1024 * 1024, // 20 MB default
    );
  }

  /// Verifies a direct upload once the client has uploaded the file directly to Cloudflare R2.
  Future<StorageUploadResult> verifyDirectUpload(
    Session session, {
    required String path,
    String? storageId,
  }) async {
    final sanitizedPath = StoragePathHelper.sanitizePath(path);
    final targetStorage = storageId ?? 'public';

    final verified = await session.storage.verifyDirectFileUpload(
      storageId: targetStorage,
      path: sanitizedPath,
    );

    if (!verified) {
      return StorageUploadResult(
        success: false,
        path: sanitizedPath,
        error: 'File upload verification failed or file not found in storage.',
      );
    }

    final publicUrl = await session.storage.getPublicUrl(
      storageId: targetStorage,
      path: sanitizedPath,
    );

    return StorageUploadResult(
      success: true,
      path: sanitizedPath,
      url: publicUrl?.toString(),
      mimeType: StoragePathHelper.resolveMimeType(sanitizedPath),
    );
  }

  /// Directly uploads a Base64-encoded file (ideal for web admin, mobile, or API calls).
  /// Automatically strips data URI prefixes (e.g. data:image/jpeg;base64,).
  Future<StorageUploadResult> uploadBase64(
    Session session, {
    required String path,
    required String base64Data,
    String? mimeType,
    String? storageId,
  }) async {
    try {
      final sanitizedPath = StoragePathHelper.sanitizePath(path);
      final targetStorage = storageId ?? 'public';

      final cleanBase64 = StoragePathHelper.stripBase64Header(base64Data);
      final bytes = base64.decode(cleanBase64);
      final byteData = ByteData.sublistView(bytes);

      await session.storage.storeFile(
        storageId: targetStorage,
        path: sanitizedPath,
        byteData: byteData,
      );

      final publicUrl = await session.storage.getPublicUrl(
        storageId: targetStorage,
        path: sanitizedPath,
      );

      final detectedMime = mimeType ?? StoragePathHelper.resolveMimeType(sanitizedPath);

      return StorageUploadResult(
        success: true,
        path: sanitizedPath,
        url: publicUrl?.toString(),
        fileSize: bytes.length,
        mimeType: detectedMime,
      );
    } catch (e) {
      return StorageUploadResult(
        success: false,
        path: path,
        error: e.toString(),
      );
    }
  }

  /// Convenience method: uploads a product or category image to Cloudflare R2
  /// and automatically returns the CDN URL.
  Future<StorageUploadResult> uploadProductImage(
    Session session, {
    required String base64Data,
    required String fileName,
    String? productSlug,
  }) async {
    final path = StoragePathHelper.generatePath(
      folder: 'products',
      filename: fileName,
      slug: productSlug,
    );

    return uploadBase64(
      session,
      path: path,
      base64Data: base64Data,
      mimeType: StoragePathHelper.resolveMimeType(fileName),
    );
  }

  /// Gets the public CDN / R2 URL for a given stored file path.
  Future<String?> getPublicUrl(
    Session session, {
    required String path,
    String? storageId,
  }) async {
    final sanitizedPath = StoragePathHelper.sanitizePath(path);
    final uri = await session.storage.getPublicUrl(
      storageId: storageId ?? 'public',
      path: sanitizedPath,
    );
    return uri?.toString();
  }

  /// Checks if a file exists in cloud storage.
  Future<bool> fileExists(
    Session session, {
    required String path,
    String? storageId,
  }) async {
    final sanitizedPath = StoragePathHelper.sanitizePath(path);
    return await session.storage.fileExists(
      storageId: storageId ?? 'public',
      path: sanitizedPath,
    );
  }

  /// Deletes a file from cloud storage.
  Future<bool> deleteFile(
    Session session, {
    required String path,
    String? storageId,
  }) async {
    final sanitizedPath = StoragePathHelper.sanitizePath(path);
    try {
      await session.storage.deleteFile(
        storageId: storageId ?? 'public',
        path: sanitizedPath,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

