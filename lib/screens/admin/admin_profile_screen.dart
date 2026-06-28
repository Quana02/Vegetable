import 'package:flutter/material.dart';

import '../../widgets/role_profile.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleProfile(
      name: 'Phạm Quốc Bảo',
      email: 'bao.admin@green.vn',
      role: 'Quản trị viên hệ thống',
      initials: 'QB',
    );
  }
}
