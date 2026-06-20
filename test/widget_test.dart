import 'package:flutter_test/flutter_test.dart';
import 'package:mechanic_service_app/main.dart';

void main() {
  testWidgets('shows demo customer home without Supabase keys', (tester) async {
    await tester.pumpWidget(const ServiceBookingApp(configured: false));
    await tester.pumpAndSettle();

    expect(find.text('FixSeva'), findsOneWidget);
    expect(find.text('Service choose karein'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
  });
}
