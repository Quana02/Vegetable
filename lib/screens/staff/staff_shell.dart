import 'package:flutter/material.dart';

import '../../widgets/adaptive_role_scaffold.dart';
import 'staff_dashboard_screen.dart';
import 'staff_profile_screen.dart';
import 'vegetable_management_screen.dart';

class StaffShell extends StatefulWidget {
  const StaffShell({super.key});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const titles = ['Tổng quan nhân viên', 'Quản lý rau', 'Hồ sơ nhân viên'];
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
          'Sản phẩm',
          Icons.inventory_2_outlined,
          Icons.inventory_2_rounded,
        ),
        RoleDestination('Hồ sơ', Icons.person_outline, Icons.person_rounded),
      ],
      body: IndexedStack(
        index: _index,
        children: const [
          StaffDashboardScreen(),
          VegetableManagementScreen(),
          StaffProfileScreen(),
        ],
      ),
    );
  }
}
