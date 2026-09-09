import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../data/receipt_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  final _receiptRepository = ReceiptRepository();
  bool _isScanning = false;

  Future<void> _pickAndScan(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    setState(() => _isScanning = true);
    try {
      final result = await _receiptRepository.scanReceipt(pickedFile.path);
      setState(() {
        if (result.amount != null) {
          _amountController.text = result.amount!.toStringAsFixed(2);
        }
        final desc = result.description;
        if (desc != null &&
            desc.trim().isNotEmpty &&
            desc.trim().toLowerCase() != 'null') {
          _descriptionController.text = desc.trim();
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt scanned — check the details below'),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('RECEIPT SCAN ERROR: $e');
      print('STACK TRACE: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not read receipt: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('New Expense', style: AppTypography.heading2(textColor)),
            const SizedBox(height: AppSpacing.md),

            // Scan receipt row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isScanning
                        ? null
                        : () => _pickAndScan(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isScanning
                        ? null
                        : () => _pickAndScan(ImageSource.gallery),
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            if (_isScanning) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Reading receipt...',
                    style: AppTypography.bodySmall(AppColors.textSecondary),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'What was this for?',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount')),
                  );
                  return;
                }
                context.read<ExpenseBloc>().add(
                  AddExpense(
                    amount: amount,
                    description: _descriptionController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save Expense'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
