import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import 'responsive_content.dart';

class RoleProfile extends StatelessWidget {
  const RoleProfile({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.initials,
  });
  final String name;
  final String email;
  final String role;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      maxWidth: 700,
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(email, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                  Chip(
                    avatar: const Icon(Icons.verified_user_outlined, size: 18),
                    label: Text(role),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.person_outline),
                  title: const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 58),
                ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.lock_outline),
                  title: const Text(
                    'Đổi mật khẩu',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
