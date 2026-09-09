import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../core/utils/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/financial_pulse.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final isMobile = Responsive.isMobile(context);

    final form = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMobile) ...[
            const Center(child: FinancialPulse(size: 88)),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text('Let\'s get you set up ✨', style: AppTypography.heading1(textColor)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'A few details, and your financial picture starts here.',
            style: AppTypography.body(AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.negative,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => context.read<AuthBloc>().add(
                          SignupRequested(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            fullName: _nameController.text.trim(),
                          ),
                        ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Account', key: ValueKey('label')),
                ),
              );
            },
          ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: form,
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF1F0FF),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FinancialPulse(size: 160),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Your money, understood.', style: AppTypography.heading2(textColor)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Center(child: form),
          ),
        ],
      ),
    );
  }
}