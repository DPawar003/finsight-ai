import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;

  ExpenseBloc({required this.expenseRepository}) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await expenseRepository.fetchExpenses();
      emit(ExpenseLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.addExpense(
        amount: event.amount,
        description: event.description,
        categoryId: event.categoryId,
      );
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.deleteExpense(event.id);
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}