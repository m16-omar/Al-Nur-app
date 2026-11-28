import 'dart:convert';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../util/cloudflare_r2_config.dart';
import '../util/storage_path_helper.dart';
import '../security/admin_auth.dart';

/// Endpoint for handling file and image uploads and storage backed by Cloudflare R2.
class StorageEndpoint extends Endpoint {
  static const _maxUploadBytes = 10 * 1024 * 1024; // 10 MB
  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif', 'avif'};

  /// Only the public bucket can be targeted from clients.
  static String _storage(String? id) {
    if (id != null && id != 'public') {
      throw ArgumentError('Unknown storage.');
    }
    return 'public';
  }

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
    AlnurAdminAuth.requireAdmin(session);
    final sanitizedPath = StoragePathHelper.sanitizePath(path);
    final targetStorage = _storage(storageId);
    return await session.storage.createDirectFileUploadDescription(
      storageId: targetStorage,
      path: sanitizedPath,
      maxFileSize: (maxFileSize == null || maxFileSize > _maxUploadBytes)
          ? _maxUploadBytes
          : maxFileSize,
    );
  }

  /// Verifies a direct upload once the client has uploaded the file directly to Cloudflare R2.
  Future<StorageUploadResult> verifyDirectUpload(
    Session session, {
    required String path,
    String? storageId,
  }) async {
    AlnurAdminAuth.requireAdmin(session);
    final sanitizedPath = StoragePathHelper.sanitizePath(path);
    final targetStorage = _storage(storageId);

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
    AlnurAdminAuth.requireAdmin(session);
    try {
      final sanitizedPath = StoragePathHelper.sanitizePath(path);
      final targetStorage = _storage(storageId);

      final ext = sanitizedPath.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        return StorageUploadResult(
          success: false,
          path: sanitizedPath,
          error: 'Only image files (jpg, png, webp, gif, avif) can be uploaded.',
        );
      }
      final cleanBase64 = StoragePathHelper.stripBase64Header(base64Data);
      final bytes = base64.decode(cleanBase64);
      if (bytes.length > _maxUploadBytes) {
        return StorageUploadResult(
          success: false,
          path: sanitizedPath,
          error: 'File is larger than 10 MB.',
        );
      }
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
      session.log('Upload failed: $e', level: LogLevel.warning);
      return StorageUploadResult(
        success: false,
        path: path,
        error: 'Upload failed. Check the file and try again.',
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
    AlnurAdminAuth.requireAdmin(session);
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
      storageId: _storage(storageId),
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
      storageId: _storage(storageId),
      path: sanitizedPath,
    );
  }

  /// Deletes a file from cloud storage.
  Future<bool> deleteFile(
    Session session, {
    required String path,
    String? storageId,
  }) async {
    AlnurAdminAuth.requireAdmin(session);
    final sanitizedPath = StoragePathHelper.sanitizePath(path);
    try {
      await session.storage.deleteFile(
        storageId: _storage(storageId),
        path: sanitizedPath,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

