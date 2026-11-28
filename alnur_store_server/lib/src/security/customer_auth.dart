import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'admin_auth.dart';

/// Ownership checks for Al-Nur Store customer data.
///
/// Customers sign in through Serverpod's email identity provider (JWT). Their
/// data is keyed by email, so every call that reads or changes customer data
/// must prove that the signed-in account owns that email.
class CustomerAuth {
  CustomerAuth._();

  /// authUserId -> email cache (emails never change for an account).
  static final Map<String, String> _emailByAuthUser = {};

  /// Email of the signed-in customer, or null if the call is not signed in
  /// with a customer account.
  static Future<String?> signedInEmail(Session session) async {
    final info = session.authenticated;
    if (info == null || info.scopes.contains(AlnurAdminAuth.scope)) return null;
    final id = info.userIdentifier;
    final cached = _emailByAuthUser[id];
    if (cached != null) return cached;
    try {
      final authUserId = UuidValue.withValidation(id);
      final account = await EmailAccount.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(authUserId),
      );
      if (account == null) return null;
      final email = account.email.trim().toLowerCase();
      _emailByAuthUser[id] = email;
      return email;
    } catch (_) {
      return null;
    }
  }

  /// True when the caller is the owner of [email] or an Al-Nur admin.
  static Future<bool> canAccess(Session session, String email) async {
    if (AlnurAdminAuth.isAdmin(session)) return true;
    final mine = await signedInEmail(session);
    return mine != null && mine == email.trim().toLowerCase();
  }

  /// Throws 401/403 unless the caller owns [email] (or is an admin).
  static Future<void> requireOwner(Session session, String email) async {
    if (AlnurAdminAuth.isAdmin(session)) return;
    final mine = await signedInEmail(session);
    if (mine == null) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
        message: 'Please sign in to continue.',
      );
    }
    if (mine != email.trim().toLowerCase()) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'You can only access your own account.',
      );
    }
  }
}
