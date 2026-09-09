
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.103:8000',
  );

  static String get graphqlUrl => '$baseUrl/graphql';

  static String get authUrl => '$baseUrl/auth';

  static String get receiptUrl => '$baseUrl/receipts';
}
