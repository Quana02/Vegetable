import 'package:flutter/material.dart';

import '../../models/user_account.dart';
import '../../widgets/role_profile.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key, required this.account});
  final UserAccount account;

  @override
  Widget build(BuildContext context) {
    return RoleProfile(
      name: account.name,
      email: account.email,
      role: 'Nhân viên cửa hàng',
      initials: _initials(account.name),
    );
  }

  String _initials(String name) {
    final words = name.trim().split(' ');
    return words.length > 1
        ? '${words[words.length - 2][0]}${words.last[0]}'.toUpperCase()
        : words.first[0].toUpperCase();
  }
}
