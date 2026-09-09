import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../bloc/expense/expense_state.dart';
import '../../data/models/expense_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/add_expense_sheet.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddExpenseSheet(),
        ),
      ),
      body: SafeArea(child:
      RefreshIndicator(
        onRefresh: () async => context.read<ExpenseBloc>().add(LoadExpenses()),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Expenses', style: AppTypography.heading1(textColor)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Every entry here helps FinSight understand your habits.',
                      style: AppTypography.body(AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            BlocConsumer<ExpenseBloc, ExpenseState>(
              listener: (context, state) {
                if (state is ExpenseError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppColors.negative),
                  );
                }
              },
              builder: (context, state) {
                if (state is ExpenseLoading || state is ExpenseInitial) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is ExpenseLoaded) {
                  if (state.expenses.isEmpty) {
                    return SliverFillRemaining(
                      child: _EmptyState(textColor: textColor),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ExpenseTile(expense: state.expenses[index]),
                        childCount: state.expenses.length,
                      ),
                    ),
                  );
                }

                return const SliverFillRemaining(child: SizedBox());
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color textColor;
  const _EmptyState({required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: AppSpacing.md),
          Text('No expenses yet', style: AppTypography.cardTitle(textColor)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Add your first one and I'll start learning your habits.",
            style: AppTypography.body(AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.negative.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.negative),
      ),
      onDismissed: (_) => context.read<ExpenseBloc>().add(DeleteExpense(expense.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.negative.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.arrow_downward, color: AppColors.negative, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description?.isNotEmpty == true ? expense.description! : 'Untitled expense',
                    style: AppTypography.cardTitle(textColor),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(expense.date),
                    style: AppTypography.bodySmall(AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '-₹${expense.amount.toStringAsFixed(2)}',
              style: AppTypography.cardTitle(AppColors.negative),
            ),
          ],
        ),
      ),
    );
  }
}