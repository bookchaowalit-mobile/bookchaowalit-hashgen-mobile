import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashgen/main.dart';
import 'package:hashgen/screens/home_screen.dart';

void main() {
  testWidgets('app shell shows hashes and about tab', (tester) async {
    await tester.pumpWidget(const HashgenApp());
    expect(find.text('Hashgen'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('typing text updates digests and compare works', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    String digest(String name) =>
        tester.widget<SelectableText>(find.byKey(Key('digest-$name'))).data!;

    await tester.enterText(find.byKey(const Key('text-input')), 'abc');
    await tester.pump();
    expect(digest('md5'), '900150983cd24fb0d6963f7d28e17f72');

    await tester.enterText(
      find.byKey(const Key('expected-input')),
      '900150983CD24FB0D6963F7D28E17F72',
    );
    await tester.pump();
    expect(find.text('Matches MD5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('hmac-switch')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('key-input')), 'k');
    await tester.pump();
    expect(digest('md5'), isNot('900150983cd24fb0d6963f7d28e17f72'));
    expect(find.text('No match'), findsOneWidget);
  });
}
