import 'package:flutter/material.dart';

import '../../widgets/role_profile.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleProfile(
      name: 'Trần Hoàng Nam',
      email: 'nam.staff@green.vn',
      role: 'Nhân viên cửa hàng',
      initials: 'HN',
    );
  }
}
