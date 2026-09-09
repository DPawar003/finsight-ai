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
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _fadeController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final isMobile = Responsive.isMobile(context);

    final form = FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMobile) ...[
                const Center(child: FinancialPulse(size: 96)),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text('Your financial picture.', style: AppTypography.heading1(textColor)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Here’s what’s happening with your finances today.",
                style: AppTypography.body(AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
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
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<AuthBloc>().add(
                                LoginRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
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
                            : const Text('Log In', key: ValueKey('label')),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.body(AppColors.textSecondary),
                      children: [
                        const TextSpan(text: "New here? "),
                        TextSpan(
                          text: 'Create an account',
                          style: AppTypography.body(AppColors.primary).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isMobile) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: form,
            ),
          ),
        ),
      );
    }

    // Desktop / tablet: split hero layout
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF1F0FF),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FinancialPulse(size: 180),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'FinSight AI',
                        style: AppTypography.heading1(textColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Turn your spending into smarter decisions.',
                        style: AppTypography.body(AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _HeroStat(label: 'You\'re doing well this month', icon: Icons.trending_up, color: AppColors.positive),
                    ],
                  ),
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

class _HeroStat extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _HeroStat({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.bodySmall(color).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}