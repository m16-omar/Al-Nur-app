/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:alnur_store_client/src/protocol/ai/ai_stylist.dart' as _i3;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i4;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i5;
import 'package:alnur_store_client/src/protocol/categories/store_category.dart'
    as _i6;
import 'package:alnur_store_client/src/protocol/greetings/greeting.dart' as _i7;
import 'package:alnur_store_client/src/protocol/orders/store_order.dart' as _i8;
import 'package:alnur_store_client/src/protocol/products/store_product.dart'
    as _i9;
import 'package:alnur_store_client/src/protocol/storage/upload_result.dart'
    as _i10;
import 'package:alnur_store_client/src/protocol/users/user_account_info.dart'
    as _i11;
import 'package:alnur_store_client/src/protocol/users/user_address.dart'
    as _i12;
import 'protocol.dart' as _i13;

/// {@category Endpoint}
class EndpointAiAssistant extends _i1.EndpointRef {
  EndpointAiAssistant(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'aiAssistant';

  /// Analyzes customer query, modesty guidelines, budget, and occasion,
  /// matching catalog products from the PostgreSQL database and providing
  /// personalized Islamic Haute Couture styling advice.
  _i2.Future<_i3.AiStylistResponse> query(
    String userQuery, {
    double? budget,
    String? occasion,
    String? preferredCategory,
  }) => caller.callServerEndpoint<_i3.AiStylistResponse>(
    'aiAssistant',
    'query',
    {
      'userQuery': userQuery,
      'budget': budget,
      'occasion': occasion,
      'preferredCategory': preferredCategory,
    },
  );
}

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i4.EndpointEmailIdpBase {
  EndpointEmailIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<_i5.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i5.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i2.Future<_i1.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i2.Future<_i5.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i5.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i2.Future<_i1.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i2.Future<String> verifyPasswordResetCode({
    required _i1.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i5.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i2.Future<_i5.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i5.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointCategory extends _i1.EndpointRef {
  EndpointCategory(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'category';

  /// Fetches all active store categories, seeding default categories if empty.
  _i2.Future<List<_i6.StoreCategory>> getCategories() =>
      caller.callServerEndpoint<List<_i6.StoreCategory>>(
        'category',
        'getCategories',
        {},
      );

  /// Creates a new category.
  _i2.Future<_i6.StoreCategory> createCategory(_i6.StoreCategory category) =>
      caller.callServerEndpoint<_i6.StoreCategory>(
        'category',
        'createCategory',
        {'category': category},
      );

  /// Updates an existing category.
  _i2.Future<_i6.StoreCategory> updateCategory(_i6.StoreCategory category) =>
      caller.callServerEndpoint<_i6.StoreCategory>(
        'category',
        'updateCategory',
        {'category': category},
      );

  /// Deletes a category by ID.
  _i2.Future<bool> deleteCategory(int id) => caller.callServerEndpoint<bool>(
    'category',
    'deleteCategory',
    {'id': id},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i7.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i7.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Endpoint for handling orders, checkout, and payment fulfillment with
/// enterprise idempotency guarantees.
/// {@category Endpoint}
class EndpointOrder extends _i1.EndpointRef {
  EndpointOrder(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'order';

  /// Places a customer order with strict enterprise idempotency protection.
  ///
  /// If the same [idempotencyKey] is sent multiple times (e.g. user double-taps
  /// checkout button or network retry occurs), the existing order is safely returned
  /// without double-charging or creating duplicate orders in the database.
  _i2.Future<_i8.StoreOrder> createOrder({
    required String? idempotencyKey,
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required double totalAmount,
    required String itemsJson,
    String? paymentReference,
  }) => caller.callServerEndpoint<_i8.StoreOrder>(
    'order',
    'createOrder',
    {
      'idempotencyKey': idempotencyKey,
      'customerEmail': customerEmail,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'totalAmount': totalAmount,
      'itemsJson': itemsJson,
      'paymentReference': paymentReference,
    },
  );

  /// Retrieves orders from PostgreSQL, optionally filtered by customer email.
  _i2.Future<List<_i8.StoreOrder>> getOrders({String? customerEmail}) =>
      caller.callServerEndpoint<List<_i8.StoreOrder>>(
        'order',
        'getOrders',
        {'customerEmail': customerEmail},
      );

  /// Processes payment gateway webhooks (Selar, Paystack, Flutterwave) idempotently.
  /// Prevents double-crediting or duplicate status notifications.
  _i2.Future<_i8.StoreOrder?> processPaymentWebhook({
    required String paymentReference,
    required String orderRef,
    required String status,
    String? idempotencyKey,
  }) => caller.callServerEndpoint<_i8.StoreOrder?>(
    'order',
    'processPaymentWebhook',
    {
      'paymentReference': paymentReference,
      'orderRef': orderRef,
      'status': status,
      'idempotencyKey': idempotencyKey,
    },
  );
}

/// {@category Endpoint}
class EndpointProduct extends _i1.EndpointRef {
  EndpointProduct(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'product';

  /// Fetches products, filtering optionally by categoryId and search query.
  /// Seeds initial Al-Nur catalog products if empty.
  _i2.Future<List<_i9.StoreProduct>> getProducts({
    String? categoryId,
    String? search,
  }) => caller.callServerEndpoint<List<_i9.StoreProduct>>(
    'product',
    'getProducts',
    {
      'categoryId': categoryId,
      'search': search,
    },
  );

  /// Fetches a single product by its database ID.
  _i2.Future<_i9.StoreProduct?> getProductById(int id) =>
      caller.callServerEndpoint<_i9.StoreProduct?>(
        'product',
        'getProductById',
        {'id': id},
      );

  /// Toggles favorite status on a product.
  _i2.Future<_i9.StoreProduct?> toggleFavorite(int productId) =>
      caller.callServerEndpoint<_i9.StoreProduct?>(
        'product',
        'toggleFavorite',
        {'productId': productId},
      );

  /// Creates a new product in the store database with optional idempotency protection.
  _i2.Future<_i9.StoreProduct> createProduct(
    _i9.StoreProduct product, {
    String? idempotencyKey,
  }) => caller.callServerEndpoint<_i9.StoreProduct>(
    'product',
    'createProduct',
    {
      'product': product,
      'idempotencyKey': idempotencyKey,
    },
  );

  /// Updates an existing product.
  _i2.Future<_i9.StoreProduct> updateProduct(_i9.StoreProduct product) =>
      caller.callServerEndpoint<_i9.StoreProduct>(
        'product',
        'updateProduct',
        {'product': product},
      );

  /// Deletes a product by ID.
  _i2.Future<bool> deleteProduct(int id) => caller.callServerEndpoint<bool>(
    'product',
    'deleteProduct',
    {'id': id},
  );
}

/// Endpoint for handling file and image uploads and storage backed by Cloudflare R2.
/// {@category Endpoint}
class EndpointStorage extends _i1.EndpointRef {
  EndpointStorage(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'storage';

  /// Checks whether Cloudflare R2 cloud storage is actively connected.
  _i2.Future<bool> isCloudflareConfigured() => caller.callServerEndpoint<bool>(
    'storage',
    'isCloudflareConfigured',
    {},
  );

  /// Creates a pre-signed direct upload description for client-to-Cloudflare direct upload.
  /// Returns a JSON description containing the PUT URL and required headers.
  _i2.Future<String?> getDirectUploadDescription({
    required String path,
    String? storageId,
    int? maxFileSize,
  }) => caller.callServerEndpoint<String?>(
    'storage',
    'getDirectUploadDescription',
    {
      'path': path,
      'storageId': storageId,
      'maxFileSize': maxFileSize,
    },
  );

  /// Verifies a direct upload once the client has uploaded the file directly to Cloudflare R2.
  _i2.Future<_i10.StorageUploadResult> verifyDirectUpload({
    required String path,
    String? storageId,
  }) => caller.callServerEndpoint<_i10.StorageUploadResult>(
    'storage',
    'verifyDirectUpload',
    {
      'path': path,
      'storageId': storageId,
    },
  );

  /// Directly uploads a Base64-encoded file (ideal for web admin, mobile, or API calls).
  /// Automatically strips data URI prefixes (e.g. data:image/jpeg;base64,).
  _i2.Future<_i10.StorageUploadResult> uploadBase64({
    required String path,
    required String base64Data,
    String? mimeType,
    String? storageId,
  }) => caller.callServerEndpoint<_i10.StorageUploadResult>(
    'storage',
    'uploadBase64',
    {
      'path': path,
      'base64Data': base64Data,
      'mimeType': mimeType,
      'storageId': storageId,
    },
  );

  /// Convenience method: uploads a product or category image to Cloudflare R2
  /// and automatically returns the CDN URL.
  _i2.Future<_i10.StorageUploadResult> uploadProductImage({
    required String base64Data,
    required String fileName,
    String? productSlug,
  }) => caller.callServerEndpoint<_i10.StorageUploadResult>(
    'storage',
    'uploadProductImage',
    {
      'base64Data': base64Data,
      'fileName': fileName,
      'productSlug': productSlug,
    },
  );

  /// Gets the public CDN / R2 URL for a given stored file path.
  _i2.Future<String?> getPublicUrl({
    required String path,
    String? storageId,
  }) => caller.callServerEndpoint<String?>(
    'storage',
    'getPublicUrl',
    {
      'path': path,
      'storageId': storageId,
    },
  );

  /// Checks if a file exists in cloud storage.
  _i2.Future<bool> fileExists({
    required String path,
    String? storageId,
  }) => caller.callServerEndpoint<bool>(
    'storage',
    'fileExists',
    {
      'path': path,
      'storageId': storageId,
    },
  );

  /// Deletes a file from cloud storage.
  _i2.Future<bool> deleteFile({
    required String path,
    String? storageId,
  }) => caller.callServerEndpoint<bool>(
    'storage',
    'deleteFile',
    {
      'path': path,
      'storageId': storageId,
    },
  );
}

/// Endpoint for managing user profiles, account details, and delivery addresses.
/// {@category Endpoint}
class EndpointUser extends _i1.EndpointRef {
  EndpointUser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  /// Fetches the profile account information for a user by email.
  /// If no profile exists yet, creates and returns a default profile.
  _i2.Future<_i11.UserAccountInfo> getProfile({required String email}) =>
      caller.callServerEndpoint<_i11.UserAccountInfo>(
        'user',
        'getProfile',
        {'email': email},
      );

  /// Updates account information (full name, phone, bio, avatarUrl, preferred currency).
  _i2.Future<_i11.UserAccountInfo> updateProfile({
    required _i11.UserAccountInfo info,
  }) => caller.callServerEndpoint<_i11.UserAccountInfo>(
    'user',
    'updateProfile',
    {'info': info},
  );

  /// Retrieves all saved delivery addresses for a customer by email.
  _i2.Future<List<_i12.UserAddress>> getAddresses({required String email}) =>
      caller.callServerEndpoint<List<_i12.UserAddress>>(
        'user',
        'getAddresses',
        {'email': email},
      );

  /// Creates or updates a delivery address.
  /// If set as default, removes default status from all other addresses of this user.
  _i2.Future<_i12.UserAddress> saveAddress({
    required _i12.UserAddress address,
  }) => caller.callServerEndpoint<_i12.UserAddress>(
    'user',
    'saveAddress',
    {'address': address},
  );

  /// Sets an address as the primary/default delivery address.
  _i2.Future<bool> setDefaultAddress({
    required int id,
    required String email,
  }) => caller.callServerEndpoint<bool>(
    'user',
    'setDefaultAddress',
    {
      'id': id,
      'email': email,
    },
  );

  /// Deletes a delivery address owned by this customer.
  _i2.Future<bool> deleteAddress({
    required int id,
    required String email,
  }) => caller.callServerEndpoint<bool>(
    'user',
    'deleteAddress',
    {
      'id': id,
      'email': email,
    },
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i4.Caller(client);
    serverpod_auth_core = _i5.Caller(client);
  }

  late final _i4.Caller serverpod_auth_idp;

  late final _i5.Caller serverpod_auth_core;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i13.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    aiAssistant = EndpointAiAssistant(this);
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    category = EndpointCategory(this);
    greeting = EndpointGreeting(this);
    order = EndpointOrder(this);
    product = EndpointProduct(this);
    storage = EndpointStorage(this);
    user = EndpointUser(this);
    modules = Modules(this);
  }

  late final EndpointAiAssistant aiAssistant;

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointCategory category;

  late final EndpointGreeting greeting;

  late final EndpointOrder order;

  late final EndpointProduct product;

  late final EndpointStorage storage;

  late final EndpointUser user;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'aiAssistant': aiAssistant,
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'category': category,
    'greeting': greeting,
    'order': order,
    'product': product,
    'storage': storage,
    'user': user,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
