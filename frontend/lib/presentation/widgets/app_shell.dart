import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

const List<NavItem> sidebarItems = [
  NavItem(Icons.space_dashboard_outlined, 'Dashboard'),
  NavItem(Icons.receipt_long_outlined, 'Transactions'),
  NavItem(Icons.account_balance_wallet_outlined, 'Budgets'),
  NavItem(Icons.category_outlined, 'Categories'),
  NavItem(Icons.query_stats_outlined, 'Analytics'),
  NavItem(Icons.auto_awesome_outlined, 'AI Insights'),
  NavItem(Icons.description_outlined, 'Reports'),
  NavItem(Icons.settings_outlined, 'Settings'),
];

const List<NavItem> mobileNavItems = [
  NavItem(Icons.home_outlined, 'Home'),
  NavItem(Icons.receipt_long_outlined, 'Transactions'),
  NavItem(Icons.query_stats_outlined, 'Analytics'),
  NavItem(Icons.auto_awesome_outlined, 'AI'),
  NavItem(Icons.person_outline, 'Profile'),
];

class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int>? onNavTap;

  const AppShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = Responsive.deviceTypeOf(context);

    if (deviceType == DeviceType.mobile) {
      return Scaffold(
        body: SafeArea(child: child),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onNavTap,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          destinations: mobileNavItems
              .map((item) => NavigationDestination(icon: Icon(item.icon), label: item.label))
              .toList(),
        ),
      );
    }

    final sidebarWidth = deviceType == DeviceType.tablet ? 84.0 : 240.0;
    final showLabels = deviceType == DeviceType.desktop;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: sidebarWidth,
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_graph, color: AppColors.primary, size: 28),
                      if (showLabels) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'FinSight AI',
                          style: AppTypography.cardTitle(
                            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: sidebarItems.length,
                    itemBuilder: (context, index) {
                      final item = sidebarItems[index];
                      final selected = index == currentIndex;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                        child: Material(
                          color: selected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            onTap: () => onNavTap?.call(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 20,
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  if (showLabels) ...[
                                    const SizedBox(width: AppSpacing.md),
                                    Text(
                                      item.label,
                                      style: AppTypography.body(
                                        selected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: SafeArea(child: child)),
        ],
      ),
    );
  }
}