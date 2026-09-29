import 'package:flutter_test/flutter_test.dart';
import 'package:mechanic_service_app/main.dart';

void main() {
  testWidgets('shows the FixMate authentication screen', (tester) async {
    await tester.pumpWidget(const ServiceBookingApp(configured: false));
    await tester.pumpAndSettle();

    expect(find.text('FixMate'), findsOneWidget);
    expect(find.text('Welcome to FixMate'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
