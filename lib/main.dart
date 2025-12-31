import 'package:flutter/material.dart';
import 'package:gestor_financiero/config/app_config.dart';
import 'package:gestor_financiero/services/api_client.dart';
import 'package:gestor_financiero/state/session.dart';
import 'package:gestor_financiero/screens/login_screen.dart';
import 'package:gestor_financiero/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = Session();
  await session.load();

  final api = ApiClient(baseUrl: AppConfig.baseUrl, token: session.token);

  runApp(MyApp(session: session, api: api));
}

class MyApp extends StatelessWidget {
  final Session session;
  final ApiClient api;

  const MyApp({super.key, required this.session, required this.api});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: session.isLoggedIn
          ? HomeScreen(session: session, api: api)
          : LoginScreen(session: session, api: api),
    );
  }
}
