import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestor_financiero/main.dart';
import 'package:gestor_financiero/state/session.dart';
import 'package:gestor_financiero/services/api_client.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    final session = Session(); // sin token → Login
    final api = ApiClient(baseUrl: 'http://test'); // fake baseUrl

    await tester.pumpWidget(MyApp(session: session, api: api));

    await tester.pump(); // render

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
