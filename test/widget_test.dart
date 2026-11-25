
import 'package:flutter_test/flutter_test.dart';
import 'package:edututors/main.dart';

void main() {
  testWidgets('EduTutors app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const EduTutorsApp());

    expect(find.byType(EduTutorsApp), findsOneWidget);
  });
}
