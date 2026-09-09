import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'core/graphql_client.dart';
import 'core/theme/app_theme.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/expense/expense_bloc.dart';
import 'data/auth_repository.dart';
import 'data/expense_repository.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/expenses_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = await GraphQLConfig.initializeClient();
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  const MyApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AuthBloc(authRepository: AuthRepository())
                  ..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (_) => ExpenseBloc(
              expenseRepository: ExpenseRepository(client: client.value),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FinSight AI',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(
                  mediaQuery.textScaler.scale(1.0).clamp(0.9, 1.15),
                ),
              ),
              child: child!,
            );
          },
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const ExpensesScreen();
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
