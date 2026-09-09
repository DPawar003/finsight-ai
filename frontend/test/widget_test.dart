import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App shows login screen when unauthenticated', (WidgetTester tester) async {
    final client = ValueNotifier(
      GraphQLClient(
        link: HttpLink('http://localhost:8000/graphql'),
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );

    await tester.pumpWidget(MyApp(client: client));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
  });
}