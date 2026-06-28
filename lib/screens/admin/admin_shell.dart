import 'package:flutter/material.dart';

import '../../widgets/adaptive_role_scaffold.dart';
import 'admin_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'manage_accounts_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Tổng quan hệ thống',
      'Quản lý tài khoản',
      'Hồ sơ quản trị',
    ];
    return AdaptiveRoleScaffold(
      title: titles[_index],
      currentIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        RoleDestination(
          'Tổng quan',
          Icons.dashboard_outlined,
          Icons.dashboard_rounded,
        ),
        RoleDestination(
          'Tài khoản',
          Icons.manage_accounts_outlined,
          Icons.manage_accounts_rounded,
        ),
        RoleDestination(
          'Hồ sơ',
          Icons.admin_panel_settings_outlined,
          Icons.admin_panel_settings_rounded,
        ),
      ],
      body: IndexedStack(
        index: _index,
        children: const [
          AdminDashboardScreen(),
          ManageAccountsScreen(),
          AdminProfileScreen(),
        ],
      ),
    );
  }
}
