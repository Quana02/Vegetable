import 'package:flutter/material.dart';

import '../../models/user_account.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_shell.dart';
import '../staff/staff_shell.dart';
import '../user/user_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@greenbasket.vn');
  final _passwordController = TextEditingController(text: '123456');
  UserRole _role = UserRole.user;
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final account = await apiClient.demoLogin(_role);
      if (!mounted) return;
      final page = switch (account.role) {
        UserRole.user => UserShell(account: account),
        UserRole.staff => StaffShell(account: account),
        UserRole.admin => AdminShell(account: account),
      };
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => page));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: Row(
        children: [
          if (wide) const Expanded(child: _LoginHero()),
          Expanded(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!wide) ...[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: AppTheme.primary,
                                child: Icon(
                                  Icons.eco_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                          Text(
                            'Chào mừng trở lại!',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đăng nhập để tiếp tục mua rau tươi mỗi ngày.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.black54),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) =>
                                value == null || !value.contains('@')
                                ? 'Vui lòng nhập email hợp lệ'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) => (value?.length ?? 0) < 6
                                ? 'Mật khẩu tối thiểu 6 ký tự'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<UserRole>(
                            initialValue: _role,
                            decoration: const InputDecoration(
                              labelText: 'Đăng nhập với vai trò',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            items: [
                              for (final role in UserRole.values)
                                DropdownMenuItem(
                                  value: role,
                                  child: Text(role.label),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _role = value ?? UserRole.user),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Chế độ demo: chọn vai trò để xem giao diện tương ứng.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.primary),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _loading ? null : _login,
                            child: _loading
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Đăng nhập'),
                          ),
                          const SizedBox(height: 18),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('hoặc'),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 18),
                          OutlinedButton.icon(
                            onPressed: _loading ? null : _login,
                            icon: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.blue,
                              ),
                            ),
                            label: const Text('Tiếp tục với Google'),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text('Chưa có tài khoản?'),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                ),
                                child: const Text('Đăng ký ngay'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -45,
            child: Icon(
              Icons.eco,
              size: 260,
              color: Colors.white.withValues(alpha: .08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.eco_rounded,
                    color: AppTheme.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Green Basket',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rau tươi từ nông trại\nđến bàn ăn của bạn.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white.withValues(alpha: .92),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeroTag(
                      icon: Icons.verified_outlined,
                      text: 'Tươi mỗi ngày',
                    ),
                    _HeroTag(
                      icon: Icons.local_shipping_outlined,
                      text: 'Giao nhanh',
                    ),
                    _HeroTag(
                      icon: Icons.health_and_safety_outlined,
                      text: 'An toàn',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
