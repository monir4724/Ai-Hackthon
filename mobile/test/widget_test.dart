import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rokkhakoboch/core/api/app_services.dart';
import 'package:rokkhakoboch/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppServices.init();
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
}
