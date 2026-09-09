import 'package:equatable/equatable.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final double amount;
  final String? description;
  final int? categoryId;

  const AddExpense({required this.amount, this.description, this.categoryId});

  @override
  List<Object?> get props => [amount, description, categoryId];
}

class DeleteExpense extends ExpenseEvent {
  final int id;
  const DeleteExpense(this.id);

  @override
  List<Object?> get props => [id];
}