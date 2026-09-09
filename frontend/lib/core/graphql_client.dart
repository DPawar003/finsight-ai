
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';

class GraphQLConfig {
  static const _storage = FlutterSecureStorage();

  static Future<ValueNotifier<GraphQLClient>> initializeClient() async {
    final token = await _storage.read(
      key: 'access_token',
    );

    print('========== GRAPHQL CONFIG ==========');
    print('GRAPHQL URL: ${AppConfig.graphqlUrl}');
    print(
      'TOKEN EXISTS: ${token != null && token.isNotEmpty}',
    );
    print('====================================');

    final httpLink = HttpLink(
      AppConfig.graphqlUrl,
      defaultHeaders: {
        'Accept': 'application/json',
      },
    );

    final authLink = AuthLink(
      getToken: () async {
        final currentToken = await _storage.read(
          key: 'access_token',
        );

        return currentToken != null && currentToken.isNotEmpty
            ? 'Bearer $currentToken'
            : null;
      },
    );

    final link = authLink.concat(httpLink);

    final client = GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: InMemoryStore(),
      ),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.networkOnly,
        ),
        mutate: Policies(
          fetch: FetchPolicy.networkOnly,
        ),
      ),
    );

    return ValueNotifier(client);
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: 'access_token',
      value: token,
    );

    print('GRAPHQL TOKEN SAVED');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(
      key: 'access_token',
    );

    print('GRAPHQL TOKEN DELETED');
  }

  static Future<String?> getToken() async {
    return await _storage.read(
      key: 'access_token',
    );
  }
}
