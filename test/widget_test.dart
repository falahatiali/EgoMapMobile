import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egomap_mobile/app.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EgoMapApp()));
    await tester.pump();

    expect(find.text('EgoMap'), findsNothing);
  });
}
