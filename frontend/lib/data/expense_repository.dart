import 'package:graphql_flutter/graphql_flutter.dart';
import 'models/expense_model.dart';

class ExpenseRepository {
  final GraphQLClient client;

  ExpenseRepository({required this.client});

  static const String _expensesQuery = r'''
    query GetExpenses {
      expenses {
        id
        amount
        description
        date
        categoryId
      }
    }
  ''';

  static const String _addExpenseMutation = r'''
    mutation AddExpense($amount: Float!, $description: String, $categoryId: Int) {
      addExpense(input: { amount: $amount, description: $description, categoryId: $categoryId }) {
        id
        amount
        description
        date
        categoryId
      }
    }
  ''';

  static const String _deleteExpenseMutation = r'''
    mutation DeleteExpense($id: Int!) {
      deleteExpense(id: $id)
    }
  ''';

  Future<List<ExpenseModel>> fetchExpenses() async {
    final result = await client.query(
      QueryOptions(document: gql(_expensesQuery), fetchPolicy: FetchPolicy.networkOnly),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['expenses'] as List<dynamic>? ?? [];
    return data.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ExpenseModel> addExpense({required double amount, String? description, int? categoryId}) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(_addExpenseMutation),
        variables: {'amount': amount, 'description': description, 'categoryId': categoryId},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return ExpenseModel.fromJson(result.data!['addExpense'] as Map<String, dynamic>);
  }

  Future<void> deleteExpense(int id) async {
    final result = await client.mutate(
      MutationOptions(document: gql(_deleteExpenseMutation), variables: {'id': id}),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }
}