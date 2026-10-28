import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_cloud_storage_r2/serverpod_cloud_storage_r2.dart';

/// Configuration and initialization manager for Cloudflare R2 Cloud Storage.
class CloudflareR2Setup {
  static bool _isConfigured = false;

  /// Returns whether Cloudflare R2 storage has been successfully configured
  /// and registered with Serverpod.
  static bool get isConfigured => _isConfigured;

  /// Configures and registers Cloudflare R2 storage with Serverpod.
  /// If credentials or account ID are not provided, it gracefully falls back
  /// to the default database storage without crashing the server.
  static bool configure(Serverpod pod) {
    // Register custom environment variable and password mappings
    pod.loadCustomPasswords([
      (envName: 'SERVERPOD_R2_ACCESS_KEY_ID', alias: 'R2AccessKeyId'),
      (envName: 'CLOUDFLARE_R2_ACCESS_KEY_ID', alias: 'R2AccessKeyId'),
      (envName: 'SERVERPOD_R2_SECRET_KEY', alias: 'R2SecretKey'),
      (envName: 'CLOUDFLARE_R2_SECRET_KEY', alias: 'R2SecretKey'),
      (envName: 'SERVERPOD_R2_ACCOUNT_ID', alias: 'r2AccountId'),
      (envName: 'CLOUDFLARE_ACCOUNT_ID', alias: 'r2AccountId'),
      (envName: 'SERVERPOD_R2_BUCKET', alias: 'r2Bucket'),
      (envName: 'CLOUDFLARE_R2_BUCKET', alias: 'r2Bucket'),
      (envName: 'SERVERPOD_R2_PUBLIC_HOST', alias: 'r2PublicHost'),
      (envName: 'CLOUDFLARE_R2_PUBLIC_HOST', alias: 'r2PublicHost'),
    ]);

    final accessKey = _sanitize(pod.getPassword('R2AccessKeyId'));
    final secretKey = _sanitize(pod.getPassword('R2SecretKey'));
    final accountId = _sanitize(pod.getPassword('r2AccountId'));
    final bucket = _sanitize(pod.getPassword('r2Bucket')) ?? 'alnur-store';
    final publicHost = _sanitize(pod.getPassword('r2PublicHost'));

    final hasCredentials =
        accessKey != null &&
        accessKey.isNotEmpty &&
        secretKey != null &&
        secretKey.isNotEmpty &&
        accountId != null &&
        accountId.isNotEmpty;

    if (!hasCredentials) {
      _isConfigured = false;
      stdout.writeln(
        'ℹ️ [Cloudflare R2] Not active: Missing credentials (R2AccessKeyId, R2SecretKey, or r2AccountId).\n'
        '   Using default Serverpod database cloud storage.\n'
        '   To enable Cloudflare R2, add your credentials to config/passwords.yaml or set environment variables.',
      );
      return false;
    }

    try {
      // Register Cloudflare R2 for the 'public' storage space
      final publicStorage = R2CloudStorage(
        serverpod: pod,
        storageId: 'public',
        public: true,
        bucket: bucket,
        accountId: accountId,
        publicHost: publicHost,
      );
      pod.addCloudStorage(publicStorage);

      _isConfigured = true;
      stdout.writeln(
        '☁️ [Cloudflare R2] Connected successfully!\n'
        '   Bucket: $bucket\n'
        '   Account ID: ${accountId.substring(0, 4)}...${accountId.substring(accountId.length > 4 ? accountId.length - 4 : 0)}\n'
        '   Public Host: ${publicHost ?? '$bucket.$accountId.r2.dev'}',
      );
      return true;
    } catch (e, st) {
      _isConfigured = false;
      stderr.writeln('⚠️ [Cloudflare R2] Initialization error: $e\n$st');
      return false;
    }
  }

  static String? _sanitize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

