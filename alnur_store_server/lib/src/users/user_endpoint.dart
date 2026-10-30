import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../util/email_service.dart';

/// Endpoint for managing user profiles, account details, and delivery addresses.
class UserEndpoint extends Endpoint {
  /// Fetches the profile account information for a user by email.
  /// If no profile exists yet, creates and returns a default profile.
  Future<UserAccountInfo> getProfile(
    Session session, {
    required String email,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    var profile = await UserAccountInfo.db.findFirstRow(
      session,
      where: (t) => t.userEmail.equals(cleanEmail),
    );

    if (profile == null) {
      final defaultName = cleanEmail.contains('@')
          ? cleanEmail.split('@')[0]
          : 'Valued Customer';

      profile = UserAccountInfo(
        userEmail: cleanEmail,
        fullName: defaultName,
        preferredCurrency: 'NGN',
      );
      profile = await UserAccountInfo.db.insertRow(session, profile);
    }

    return profile;
  }

  /// Updates account information (full name, phone, bio, avatarUrl, preferred currency).
  Future<UserAccountInfo> updateProfile(
    Session session, {
    required UserAccountInfo info,
  }) async {
    final cleanEmail = info.userEmail.trim().toLowerCase();
    final existing = await UserAccountInfo.db.findFirstRow(
      session,
      where: (t) => t.userEmail.equals(cleanEmail),
    );

    if (existing == null) {
      return await UserAccountInfo.db.insertRow(
        session,
        info.copyWith(userEmail: cleanEmail),
      );
    }

    final updated = existing.copyWith(
      fullName: info.fullName.trim(),
      phoneNumber: info.phoneNumber?.trim(),
      avatarUrl: info.avatarUrl?.trim(),
      preferredCurrency: info.preferredCurrency?.trim() ?? 'NGN',
      bio: info.bio?.trim(),
    );

    return await UserAccountInfo.db.updateRow(session, updated);
  }

  /// Retrieves all saved delivery addresses for a customer by email.
  Future<List<UserAddress>> getAddresses(
    Session session, {
    required String email,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final addresses = await UserAddress.db.find(
      session,
      where: (t) => t.userEmail.equals(cleanEmail),
      orderBy: (t) => t.id,
      orderDescending: true,
    );

    // Sort default address first
    addresses.sort((a, b) {
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      return (b.id ?? 0).compareTo(a.id ?? 0);
    });

    return addresses;
  }

  /// Creates or updates a delivery address.
  /// If set as default, removes default status from all other addresses of this user.
  Future<UserAddress> saveAddress(
    Session session, {
    required UserAddress address,
  }) async {
    final cleanEmail = address.userEmail.trim().toLowerCase();

    // If marked as default, unset any existing default address
    if (address.isDefault) {
      final existingDefaults = await UserAddress.db.find(
        session,
        where: (t) => t.userEmail.equals(cleanEmail) & t.isDefault.equals(true),
      );
      for (final def in existingDefaults) {
        if (address.id == null || def.id != address.id) {
          await UserAddress.db.updateRow(
            session,
            def.copyWith(isDefault: false),
          );
        }
      }
    }

    final sanitizedAddress = address.copyWith(
      userEmail: cleanEmail,
      title: address.title.trim().isNotEmpty ? address.title.trim() : 'Home',
      recipientName: address.recipientName.trim(),
      phoneNumber: address.phoneNumber.trim(),
      streetAddress: address.streetAddress.trim(),
      city: address.city.trim(),
      state: address.state.trim(),
      country: address.country?.trim() ?? 'Nigeria',
      postalCode: address.postalCode?.trim(),
      additionalInstructions: address.additionalInstructions?.trim(),
    );

    if (sanitizedAddress.id != null) {
      return await UserAddress.db.updateRow(session, sanitizedAddress);
    } else {
      return await UserAddress.db.insertRow(session, sanitizedAddress);
    }
  }

  /// Sets an address as the primary/default delivery address.
  Future<bool> setDefaultAddress(
    Session session, {
    required int id,
    required String email,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final address = await UserAddress.db.findById(session, id);
    if (address == null || address.userEmail.toLowerCase() != cleanEmail) {
      return false;
    }

    // Unset all defaults
    final allAddresses = await UserAddress.db.find(
      session,
      where: (t) => t.userEmail.equals(cleanEmail),
    );
    for (final a in allAddresses) {
      if (a.isDefault && a.id != id) {
        await UserAddress.db.updateRow(session, a.copyWith(isDefault: false));
      }
    }

    // Set this address as default
    await UserAddress.db.updateRow(session, address.copyWith(isDefault: true));
    return true;
  }

  /// Deletes a delivery address owned by this customer.
  Future<bool> deleteAddress(
    Session session, {
    required int id,
    required String email,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final address = await UserAddress.db.findById(session, id);
    if (address == null || address.userEmail.toLowerCase() != cleanEmail) {
      return false;
    }

    await UserAddress.db.deleteRow(session, address);
    return true;
  }

  /// Dispatches the VIP luxury welcome email to a new patron.
  Future<bool> sendWelcomeEmail(
    Session session, {
    required String email,
    String? name,
  }) async {
    return await EmailService.sendWelcomeEmail(
      session,
      email: email.trim().toLowerCase(),
      name: name,
    );
  }
}
