import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const HomeScreen(),
        ),
      );

  testWidgets('explains wrong-length digests and HMAC matches', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(home());
    await tester.enterText(find.byKey(const Key('expected-input')), 'deadbeef');
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('match-result'))).data,
      startsWith('No match: 8 hex characters'),
    );

    await tester.tap(find.byKey(const Key('hmac-switch')));
    await tester.pump();
    final hmac = tester
        .widget<SelectableText>(find.byKey(const Key('digest-sha256')))
        .data!;
    await tester.enterText(
      find.byKey(const Key('expected-input')),
      '$hmac  message.txt',
    );
    await tester.pump();
    expect(find.text('Matches HMAC-SHA-256'), findsOneWidget);
  });

  testWidgets('copy puts the digest on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await tester.pumpWidget(home());
    await tester.tap(find.byTooltip('Copy MD5'));
    await tester.pump();
    expect(copied, '5d41402abc4b2a76b9719d911017c592'); // md5("hello")
    expect(find.text('MD5 copied'), findsOneWidget);
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('lays out at 200% text scale on a phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
