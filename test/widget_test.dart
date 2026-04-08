import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uomo_90_giorni/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Uomo90App(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('UOMO IN 90 GIORNI'), findsOneWidget);
  });
}
