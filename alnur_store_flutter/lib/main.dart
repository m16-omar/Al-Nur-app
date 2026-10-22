import 'package:alnur_store_client/alnur_store_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'app.dart';

late final Client client;
late String serverUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  serverUrl = await getServerUrl();

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
