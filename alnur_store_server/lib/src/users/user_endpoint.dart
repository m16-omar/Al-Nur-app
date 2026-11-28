import 'dart:async';
import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../security/admin_auth.dart';
import '../security/customer_auth.dart';
import '../security/input_sanitizer.dart';
import '../security/rate_limiter.dart';
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
    await CustomerAuth.requireOwner(session, cleanEmail);
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
    await CustomerAuth.requireOwner(session, cleanEmail);
    info = info.copyWith(
      id: null,
      fullName: InputSanitizer.text(info.fullName, maxLength: 120),
      phoneNumber: InputSanitizer.phone(info.phoneNumber),
      avatarUrl: InputSanitizer.imageUrl(info.avatarUrl),
      bio: InputSanitizer.optionalText(info.bio, maxLength: 500, multiline: true),
      preferredCurrency: InputSanitizer.optionalText(info.preferredCurrency, maxLength: 8),
    );
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
      fullName: info.fullName,
      phoneNumber: info.phoneNumber,
      avatarUrl: info.avatarUrl,
      preferredCurrency: info.preferredCurrency ?? 'NGN',
      bio: info.bio,
    );

    return await UserAccountInfo.db.updateRow(session, updated);
  }

  /// Retrieves all saved delivery addresses for a customer by email.
  Future<List<UserAddress>> getAddresses(
    Session session, {
    required String email,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    await CustomerAuth.requireOwner(session, cleanEmail);
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
    await CustomerAuth.requireOwner(session, cleanEmail);

    // Updating an existing address: it must belong to the same account
    // (stops one customer overwriting another customer's address by id).
    if (address.id != null) {
      final existing = await UserAddress.db.findById(session, address.id!);
      if (existing == null || existing.userEmail.trim().toLowerCase() != cleanEmail) {
        throw NotAuthorizedException(
          reason: AuthenticationFailureReason.insufficientAccess,
          message: 'Address not found.',
        );
      }
    }

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
      title: InputSanitizer.text(address.title, maxLength: 60).isNotEmpty
          ? InputSanitizer.text(address.title, maxLength: 60)
          : 'Home',
      recipientName: InputSanitizer.text(address.recipientName, maxLength: 120),
      phoneNumber: InputSanitizer.phone(address.phoneNumber),
      streetAddress: InputSanitizer.text(address.streetAddress, maxLength: 300),
      city: InputSanitizer.text(address.city, maxLength: 80),
      state: InputSanitizer.text(address.state, maxLength: 80),
      country: InputSanitizer.optionalText(address.country, maxLength: 80) ?? 'Nigeria',
      postalCode: InputSanitizer.optionalText(address.postalCode, maxLength: 20),
      additionalInstructions: InputSanitizer.optionalText(
          address.additionalInstructions, maxLength: 500, multiline: true),
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
    await CustomerAuth.requireOwner(session, cleanEmail);
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
    await CustomerAuth.requireOwner(session, cleanEmail);
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
    final cleanEmail = email.trim().toLowerCase();
    // Only the signed-in owner, and at most 3 per hour, so this can't be used
    // to spam arbitrary inboxes.
    if (!await CustomerAuth.canAccess(session, cleanEmail)) return false;
    if (!RateLimiter.hit('welcome-email|$cleanEmail',
        max: 3, window: const Duration(hours: 1))) {
      return false;
    }
    return await EmailService.sendWelcomeEmail(
      session,
      email: cleanEmail,
      name: InputSanitizer.optionalText(name, maxLength: 80),
    );
  }

  /// Registers or updates a customer profile and ensures it is persisted in the PostgreSQL database.
  Future<UserAccountInfo> registerCustomer(
    Session session, {
    required String email,
    required String fullName,
    String? phoneNumber,
  }) async {
    RateLimiter.enforce(session, 'user.registerCustomer',
        max: 10, window: const Duration(hours: 1));
    final cleanEmail = InputSanitizer.email(email);
    if (cleanEmail.isEmpty) throw ArgumentError('A valid email is required.');
    final safeName = InputSanitizer.text(fullName, maxLength: 120);
    final cleanName = safeName.isNotEmpty
        ? safeName
        : cleanEmail.split('@')[0];
    final cleanPhone =
        phoneNumber == null ? null : InputSanitizer.phone(phoneNumber);

    var profile = await UserAccountInfo.db.findFirstRow(
      session,
      where: (t) => t.userEmail.equals(cleanEmail),
    );

    var isNew = false;
    if (profile == null) {
      profile = UserAccountInfo(
        userEmail: cleanEmail,
        fullName: cleanName,
        phoneNumber: cleanPhone,
        preferredCurrency: 'NGN',
      );
      profile = await UserAccountInfo.db.insertRow(session, profile);
      isNew = true;
    } else {
      // Changing an existing profile requires being signed in as its owner.
      await CustomerAuth.requireOwner(session, cleanEmail);
      profile = profile.copyWith(
        fullName: cleanName,
        phoneNumber: cleanPhone ?? profile.phoneNumber,
      );
      profile = await UserAccountInfo.db.updateRow(session, profile);
    }

    // Welcome email only for a newly created profile (not on every call).
    if (isNew) {
      try {
        unawaited(
          EmailService.sendWelcomeEmail(
            session,
            email: cleanEmail,
            name: cleanName,
          ),
        );
      } catch (_) {}
    }

    return profile;
  }

  /// Retrieves live registered customers and buyers directly from PostgreSQL database.
  Future<String> getAdminCustomers(Session session) async {
    AlnurAdminAuth.requireAdmin(session);
    final adminEmail = AlnurAdminAuth.credentials()?.email;
    // 1. Fetch all user accounts
    final accounts = await UserAccountInfo.db.find(
      session,
      orderBy: (t) => t.id,
      orderDescending: true,
    );

    // 2. Fetch all orders to compute real order counts and lifetime spend
    final orders = await StoreOrder.db.find(
      session,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    // 3. Fetch all saved addresses for location and contact info
    final addresses = await UserAddress.db.find(session);

    // Map addresses by email
    final addressMap = <String, UserAddress>{};
    for (final addr in addresses) {
      final emailKey = addr.userEmail.trim().toLowerCase();
      if (!addressMap.containsKey(emailKey) || addr.isDefault) {
        addressMap[emailKey] = addr;
      }
    }

    // Map orders by email
    final ordersMap = <String, List<StoreOrder>>{};
    for (final ord in orders) {
      final emailKey = ord.customerEmail.trim().toLowerCase();
      ordersMap.putIfAbsent(emailKey, () => []).add(ord);
    }

    // Combine all unique customer emails
    final allEmails = <String>{};
    for (final acc in accounts) {
      allEmails.add(acc.userEmail.trim().toLowerCase());
    }
    for (final ord in orders) {
      allEmails.add(ord.customerEmail.trim().toLowerCase());
    }

    final accountsMap = {
      for (final a in accounts) a.userEmail.trim().toLowerCase(): a,
    };

    final resultList = <Map<String, dynamic>>[];
    var idCounter = 1;

    for (final email in allEmails) {
      final account = accountsMap[email];
      final userOrders = ordersMap[email] ?? [];
      final userAddress = addressMap[email];

      // Calculate total spend & orders count
      final ordersCount = userOrders.length;
      double lifetimeSpend = 0.0;
      for (final o in userOrders) {
        final pStatus = o.paymentStatus.toLowerCase();
        if (pStatus.contains('paid') || pStatus.contains('verified')) {
          lifetimeSpend += o.totalAmount;
        }
      }

      // Check last order date
      String? lastOrderDateStr;
      bool isDormantSixMonths = false;
      if (userOrders.isNotEmpty) {
        final latestOrder = userOrders.first;
        final orderDate = latestOrder.createdAt;
        final diff = DateTime.now().difference(orderDate);
        if (diff.inDays < 1) {
          lastOrderDateStr = diff.inHours <= 1 ? '1 hour ago' : '${diff.inHours} hours ago';
        } else if (diff.inDays == 1) {
          lastOrderDateStr = 'Yesterday';
        } else if (diff.inDays < 7) {
          lastOrderDateStr = '${diff.inDays} days ago';
        } else if (diff.inDays < 30) {
          lastOrderDateStr = '${(diff.inDays / 7).floor()} weeks ago';
        } else {
          lastOrderDateStr = '${(diff.inDays / 30).floor()} months ago';
        }

        if (diff.inDays > 180) {
          isDormantSixMonths = true;
        }
      }

      // Determine name
      String name = 'Valued Customer';
      if (account != null && account.fullName.trim().isNotEmpty) {
        name = account.fullName.trim();
      } else if (userOrders.isNotEmpty && userOrders.first.customerName.trim().isNotEmpty) {
        name = userOrders.first.customerName.trim();
      } else if (userAddress != null && userAddress.recipientName.trim().isNotEmpty) {
        name = userAddress.recipientName.trim();
      } else if (email.contains('@')) {
        name = email.split('@')[0];
      }

      // Determine phone
      String phone = '';
      if (account?.phoneNumber != null && account!.phoneNumber!.trim().isNotEmpty) {
        phone = account.phoneNumber!.trim();
      } else if (userAddress != null && userAddress.phoneNumber.trim().isNotEmpty) {
        phone = userAddress.phoneNumber.trim();
      } else if (userOrders.isNotEmpty && userOrders.first.customerPhone.trim().isNotEmpty) {
        phone = userOrders.first.customerPhone.trim();
      }

      // Determine location
      String location = 'Nigeria';
      if (userAddress != null) {
        location = '${userAddress.city}, ${userAddress.state}';
      } else if (userOrders.isNotEmpty && userOrders.first.shippingAddress.trim().isNotEmpty) {
        location = userOrders.first.shippingAddress.trim();
      }

      // Determine role
      String role = 'Customer';
      if (adminEmail != null && email == adminEmail) {
        role = 'Super Administrator';
      } else if (lifetimeSpend >= 200000 || ordersCount >= 5) {
        role = 'VIP Gold Member';
      }

      resultList.add({
        'id': account?.id ?? idCounter++,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'sizeProfile': account?.bio ?? 'Abaya / Thobe Patron',
        'location': location,
        'ordersCount': ordersCount,
        'lifetimeSpend': lifetimeSpend,
        'lastOrderDate': lastOrderDateStr,
        'isDormantSixMonths': isDormantSixMonths,
        'status': 'Active',
        'isOnline': false,
        'currentActivity': 'Offline',
        'lastSeen': 'Recently',
      });
    }

    return jsonEncode(resultList);
  }
}
