import 'package:alnur_store_client/alnur_store_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'app.dart';
import 'core/constants/api_constants.dart';

late final Client client;
late String serverUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final configuredUrl = await getServerUrl();
    serverUrl = configuredUrl.startsWith('https://')
        ? configuredUrl
        : ApiConstants.defaultServerUrl;
  } catch (_) {
    serverUrl = ApiConstants.defaultServerUrl;
  }

  debugPrint("🚀 Al-Nur Store connected to Serverpod Cloud: $serverUrl");

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  client.auth.initialize();

  runApp(
    const ProviderScope(
      child: AlNurApp(),
    ),
  );
}
