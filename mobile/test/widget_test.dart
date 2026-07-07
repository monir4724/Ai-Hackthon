import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rokkhakoboch/core/api/app_services.dart';
import 'package:rokkhakoboch/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await AppServices.init(skipPushAndSms: true);
  });

  testWidgets('App shell renders bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const RokkhakobochApp());
    await tester.pumpAndSettle();

    expect(find.text('হোম'), findsOneWidget);
    expect(find.text('স্ক্যান'), findsOneWidget);
    expect(find.text('ফিড'), findsOneWidget);
    expect(find.text('মডিউল'), findsOneWidget);
    expect(find.text('ইতিহাস'), findsOneWidget);
    expect(find.text('টাকা হারানোর আগেই ধরা পড়বে'), findsOneWidget);
  });

  testWidgets('Settings reachable from home', (WidgetTester tester) async {
    await tester.pumpWidget(const RokkhakobochApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('সেটিংস'), findsOneWidget);
  });

  testWidgets('Modules screen lists active modules', (WidgetTester tester) async {
    await tester.pumpWidget(const RokkhakobochApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('মডিউল'));
    await tester.pumpAndSettle();

    expect(find.text('১০-মডিউল সুরক্ষা আর্কিটেকচার'), findsOneWidget);
    expect(find.text('আর্থিক প্রতারণা শিল্ড'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('জাতীয় হুমকি'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('জাতীয় হুমকি'), findsOneWidget);
  });
}
