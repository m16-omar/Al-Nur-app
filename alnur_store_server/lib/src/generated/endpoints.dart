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

import 'package:serverpod/serverpod.dart' as _i1;
import '../ai/ai_assistant_endpoint.dart' as _i2;
import '../auth/email_idp_endpoint.dart' as _i3;
import '../auth/jwt_refresh_endpoint.dart' as _i4;
import '../categories/category_endpoint.dart' as _i5;
import '../greetings/greeting_endpoint.dart' as _i6;
import '../orders/order_endpoint.dart' as _i7;
import '../products/product_endpoint.dart' as _i8;
import '../storage/storage_endpoint.dart' as _i9;
import '../users/user_endpoint.dart' as _i10;
import 'package:alnur_store_server/src/generated/categories/store_category.dart'
    as _i11;
import 'package:alnur_store_server/src/generated/products/store_product.dart'
    as _i12;
import 'package:alnur_store_server/src/generated/users/user_account_info.dart'
    as _i13;
import 'package:alnur_store_server/src/generated/users/user_address.dart'
    as _i14;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i15;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i16;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'aiAssistant': _i2.AiAssistantEndpoint()
        ..initialize(
          server,
          'aiAssistant',
          null,
        ),
      'emailIdp': _i3.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i4.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'category': _i5.CategoryEndpoint()
        ..initialize(
          server,
          'category',
          null,
        ),
      'greeting': _i6.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'order': _i7.OrderEndpoint()
        ..initialize(
          server,
          'order',
          null,
        ),
      'product': _i8.ProductEndpoint()
        ..initialize(
          server,
          'product',
          null,
        ),
      'storage': _i9.StorageEndpoint()
        ..initialize(
          server,
          'storage',
          null,
        ),
      'user': _i10.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
    };
    connectors['aiAssistant'] = _i1.EndpointConnector(
      name: 'aiAssistant',
      endpoint: endpoints['aiAssistant']!,
      methodConnectors: {
        'query': _i1.MethodConnector(
          name: 'query',
          params: {
            'userQuery': _i1.ParameterDescription(
              name: 'userQuery',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'budget': _i1.ParameterDescription(
              name: 'budget',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'occasion': _i1.ParameterDescription(
              name: 'occasion',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'preferredCategory': _i1.ParameterDescription(
              name: 'preferredCategory',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['aiAssistant'] as _i2.AiAssistantEndpoint).query(
                    session,
                    params['userQuery'],
                    budget: params['budget'],
                    occasion: params['occasion'],
                    preferredCategory: params['preferredCategory'],
                  ),
        ),
      },
    );
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i4.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['category'] = _i1.EndpointConnector(
      name: 'category',
      endpoint: endpoints['category']!,
      methodConnectors: {
        'getCategories': _i1.MethodConnector(
          name: 'getCategories',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i5.CategoryEndpoint)
                  .getCategories(session),
        ),
        'reseedCategories': _i1.MethodConnector(
          name: 'reseedCategories',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i5.CategoryEndpoint)
                  .reseedCategories(session),
        ),
        'createCategory': _i1.MethodConnector(
          name: 'createCategory',
          params: {
            'category': _i1.ParameterDescription(
              name: 'category',
              type: _i1.getType<_i11.StoreCategory>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i5.CategoryEndpoint)
                  .createCategory(
                    session,
                    params['category'],
                  ),
        ),
        'updateCategory': _i1.MethodConnector(
          name: 'updateCategory',
          params: {
            'category': _i1.ParameterDescription(
              name: 'category',
              type: _i1.getType<_i11.StoreCategory>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i5.CategoryEndpoint)
                  .updateCategory(
                    session,
                    params['category'],
                  ),
        ),
        'deleteCategory': _i1.MethodConnector(
          name: 'deleteCategory',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i5.CategoryEndpoint)
                  .deleteCategory(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i6.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['order'] = _i1.EndpointConnector(
      name: 'order',
      endpoint: endpoints['order']!,
      methodConnectors: {
        'createOrder': _i1.MethodConnector(
          name: 'createOrder',
          params: {
            'idempotencyKey': _i1.ParameterDescription(
              name: 'idempotencyKey',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'customerEmail': _i1.ParameterDescription(
              name: 'customerEmail',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'customerName': _i1.ParameterDescription(
              name: 'customerName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'customerPhone': _i1.ParameterDescription(
              name: 'customerPhone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'shippingAddress': _i1.ParameterDescription(
              name: 'shippingAddress',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'totalAmount': _i1.ParameterDescription(
              name: 'totalAmount',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'itemsJson': _i1.ParameterDescription(
              name: 'itemsJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'paymentReference': _i1.ParameterDescription(
              name: 'paymentReference',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['order'] as _i7.OrderEndpoint).createOrder(
                session,
                idempotencyKey: params['idempotencyKey'],
                customerEmail: params['customerEmail'],
                customerName: params['customerName'],
                customerPhone: params['customerPhone'],
                shippingAddress: params['shippingAddress'],
                totalAmount: params['totalAmount'],
                itemsJson: params['itemsJson'],
                paymentReference: params['paymentReference'],
              ),
        ),
        'getOrders': _i1.MethodConnector(
          name: 'getOrders',
          params: {
            'customerEmail': _i1.ParameterDescription(
              name: 'customerEmail',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['order'] as _i7.OrderEndpoint).getOrders(
                session,
                customerEmail: params['customerEmail'],
              ),
        ),
        'initializeMonnifyPayment': _i1.MethodConnector(
          name: 'initializeMonnifyPayment',
          params: {
            'amount': _i1.ParameterDescription(
              name: 'amount',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'customerName': _i1.ParameterDescription(
              name: 'customerName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'customerEmail': _i1.ParameterDescription(
              name: 'customerEmail',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'orderRef': _i1.ParameterDescription(
              name: 'orderRef',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'customerPhone': _i1.ParameterDescription(
              name: 'customerPhone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['order'] as _i7.OrderEndpoint)
                  .initializeMonnifyPayment(
                    session,
                    amount: params['amount'],
                    customerName: params['customerName'],
                    customerEmail: params['customerEmail'],
                    orderRef: params['orderRef'],
                    customerPhone: params['customerPhone'],
                  ),
        ),
        'processPaymentWebhook': _i1.MethodConnector(
          name: 'processPaymentWebhook',
          params: {
            'paymentReference': _i1.ParameterDescription(
              name: 'paymentReference',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'orderRef': _i1.ParameterDescription(
              name: 'orderRef',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'idempotencyKey': _i1.ParameterDescription(
              name: 'idempotencyKey',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['order'] as _i7.OrderEndpoint)
                  .processPaymentWebhook(
                    session,
                    paymentReference: params['paymentReference'],
                    orderRef: params['orderRef'],
                    status: params['status'],
                    idempotencyKey: params['idempotencyKey'],
                  ),
        ),
        'updateOrderStatus': _i1.MethodConnector(
          name: 'updateOrderStatus',
          params: {
            'orderRef': _i1.ParameterDescription(
              name: 'orderRef',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fulfillmentStatus': _i1.ParameterDescription(
              name: 'fulfillmentStatus',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['order'] as _i7.OrderEndpoint).updateOrderStatus(
                    session,
                    orderRef: params['orderRef'],
                    fulfillmentStatus: params['fulfillmentStatus'],
                  ),
        ),
        'updatePaymentStatus': _i1.MethodConnector(
          name: 'updatePaymentStatus',
          params: {
            'orderRef': _i1.ParameterDescription(
              name: 'orderRef',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'paymentStatus': _i1.ParameterDescription(
              name: 'paymentStatus',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'paymentReference': _i1.ParameterDescription(
              name: 'paymentReference',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['order'] as _i7.OrderEndpoint).updatePaymentStatus(
                    session,
                    orderRef: params['orderRef'],
                    paymentStatus: params['paymentStatus'],
                    paymentReference: params['paymentReference'],
                  ),
        ),
        'deleteOrder': _i1.MethodConnector(
          name: 'deleteOrder',
          params: {
            'orderRef': _i1.ParameterDescription(
              name: 'orderRef',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['order'] as _i7.OrderEndpoint).deleteOrder(
                session,
                orderRef: params['orderRef'],
              ),
        ),
      },
    );
    connectors['product'] = _i1.EndpointConnector(
      name: 'product',
      endpoint: endpoints['product']!,
      methodConnectors: {
        'getProducts': _i1.MethodConnector(
          name: 'getProducts',
          params: {
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'search': _i1.ParameterDescription(
              name: 'search',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _i8.ProductEndpoint).getProducts(
                    session,
                    categoryId: params['categoryId'],
                    search: params['search'],
                  ),
        ),
        'reseedProducts': _i1.MethodConnector(
          name: 'reseedProducts',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _i8.ProductEndpoint)
                  .reseedProducts(session),
        ),
        'getProductById': _i1.MethodConnector(
          name: 'getProductById',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _i8.ProductEndpoint).getProductById(
                    session,
                    params['id'],
                  ),
        ),
        'toggleFavorite': _i1.MethodConnector(
          name: 'toggleFavorite',
          params: {
            'productId': _i1.ParameterDescription(
              name: 'productId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _i8.ProductEndpoint).toggleFavorite(
                    session,
                    params['productId'],
                  ),
        ),
        'createProduct': _i1.MethodConnector(
          name: 'createProduct',
          params: {
            'product': _i1.ParameterDescription(
              name: 'product',
              type: _i1.getType<_i12.StoreProduct>(),
              nullable: false,
            ),
            'idempotencyKey': _i1.ParameterDescription(
              name: 'idempotencyKey',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _i8.ProductEndpoint).createProduct(
                    session,
                    params['product'],
                    idempotencyKey: params['idempotencyKey'],
                  ),
        ),
        'updateProduct': _i1.MethodConnector(
          name: 'updateProduct',
          params: {
            'product': _i1.ParameterDescription(
              name: 'product',
              type: _i1.getType<_i12.StoreProduct>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _i8.ProductEndpoint).updateProduct(
                    session,
                    params['product'],
                  ),
        ),
        'deleteProduct': _i1.MethodConnector(
          name: 'deleteProduct',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _i8.ProductEndpoint).deleteProduct(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['storage'] = _i1.EndpointConnector(
      name: 'storage',
      endpoint: endpoints['storage']!,
      methodConnectors: {
        'isCloudflareConfigured': _i1.MethodConnector(
          name: 'isCloudflareConfigured',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['storage'] as _i9.StorageEndpoint)
                  .isCloudflareConfigured(session),
        ),
        'getDirectUploadDescription': _i1.MethodConnector(
          name: 'getDirectUploadDescription',
          params: {
            'path': _i1.ParameterDescription(
              name: 'path',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'storageId': _i1.ParameterDescription(
              name: 'storageId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'maxFileSize': _i1.ParameterDescription(
              name: 'maxFileSize',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['storage'] as _i9.StorageEndpoint)
                  .getDirectUploadDescription(
                    session,
                    path: params['path'],
                    storageId: params['storageId'],
                    maxFileSize: params['maxFileSize'],
                  ),
        ),
        'verifyDirectUpload': _i1.MethodConnector(
          name: 'verifyDirectUpload',
          params: {
            'path': _i1.ParameterDescription(
              name: 'path',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'storageId': _i1.ParameterDescription(
              name: 'storageId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['storage'] as _i9.StorageEndpoint)
                  .verifyDirectUpload(
                    session,
                    path: params['path'],
                    storageId: params['storageId'],
                  ),
        ),
        'uploadBase64': _i1.MethodConnector(
          name: 'uploadBase64',
          params: {
            'path': _i1.ParameterDescription(
              name: 'path',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'base64Data': _i1.ParameterDescription(
              name: 'base64Data',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'mimeType': _i1.ParameterDescription(
              name: 'mimeType',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'storageId': _i1.ParameterDescription(
              name: 'storageId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['storage'] as _i9.StorageEndpoint).uploadBase64(
                    session,
                    path: params['path'],
                    base64Data: params['base64Data'],
                    mimeType: params['mimeType'],
                    storageId: params['storageId'],
                  ),
        ),
        'uploadProductImage': _i1.MethodConnector(
          name: 'uploadProductImage',
          params: {
            'base64Data': _i1.ParameterDescription(
              name: 'base64Data',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'productSlug': _i1.ParameterDescription(
              name: 'productSlug',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['storage'] as _i9.StorageEndpoint)
                  .uploadProductImage(
                    session,
                    base64Data: params['base64Data'],
                    fileName: params['fileName'],
                    productSlug: params['productSlug'],
                  ),
        ),
        'getPublicUrl': _i1.MethodConnector(
          name: 'getPublicUrl',
          params: {
            'path': _i1.ParameterDescription(
              name: 'path',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'storageId': _i1.ParameterDescription(
              name: 'storageId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['storage'] as _i9.StorageEndpoint).getPublicUrl(
                    session,
                    path: params['path'],
                    storageId: params['storageId'],
                  ),
        ),
        'fileExists': _i1.MethodConnector(
          name: 'fileExists',
          params: {
            'path': _i1.ParameterDescription(
              name: 'path',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'storageId': _i1.ParameterDescription(
              name: 'storageId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['storage'] as _i9.StorageEndpoint).fileExists(
                    session,
                    path: params['path'],
                    storageId: params['storageId'],
                  ),
        ),
        'deleteFile': _i1.MethodConnector(
          name: 'deleteFile',
          params: {
            'path': _i1.ParameterDescription(
              name: 'path',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'storageId': _i1.ParameterDescription(
              name: 'storageId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['storage'] as _i9.StorageEndpoint).deleteFile(
                    session,
                    path: params['path'],
                    storageId: params['storageId'],
                  ),
        ),
      },
    );
    connectors['user'] = _i1.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'getProfile': _i1.MethodConnector(
          name: 'getProfile',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).getProfile(
                session,
                email: params['email'],
              ),
        ),
        'updateProfile': _i1.MethodConnector(
          name: 'updateProfile',
          params: {
            'info': _i1.ParameterDescription(
              name: 'info',
              type: _i1.getType<_i13.UserAccountInfo>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).updateProfile(
                session,
                info: params['info'],
              ),
        ),
        'getAddresses': _i1.MethodConnector(
          name: 'getAddresses',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).getAddresses(
                session,
                email: params['email'],
              ),
        ),
        'saveAddress': _i1.MethodConnector(
          name: 'saveAddress',
          params: {
            'address': _i1.ParameterDescription(
              name: 'address',
              type: _i1.getType<_i14.UserAddress>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).saveAddress(
                session,
                address: params['address'],
              ),
        ),
        'setDefaultAddress': _i1.MethodConnector(
          name: 'setDefaultAddress',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).setDefaultAddress(
                    session,
                    id: params['id'],
                    email: params['email'],
                  ),
        ),
        'deleteAddress': _i1.MethodConnector(
          name: 'deleteAddress',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).deleteAddress(
                session,
                id: params['id'],
                email: params['email'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i15.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i16.Endpoints()
      ..initializeEndpoints(server);
  }
}
