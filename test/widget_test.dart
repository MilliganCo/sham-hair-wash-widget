import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sham/app/sham_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('renders terminal dashboard', (tester) async {
    await tester.pumpWidget(const ShamApp());
    await tester.pumpAndSettle();

    expect(find.text('HEAD.WASH'), findsWidgets);
    expect(find.text('[ config ]'), findsOneWidget);
    expect(find.text('[ log today ]'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });
}
