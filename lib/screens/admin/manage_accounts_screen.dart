import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/user_account.dart';
import '../../widgets/responsive_content.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  late final List<UserAccount> _accounts = List.of(mockAccounts);
  String _query = '';
  UserRole? _roleFilter;

  List<UserAccount> get _filtered => _accounts.where((account) {
    final query = _query.toLowerCase();
    return (account.name.toLowerCase().contains(query) ||
            account.email.toLowerCase().contains(query)) &&
        (_roleFilter == null || account.role == _roleFilter);
  }).toList();

  Future<void> _openForm([UserAccount? account]) async {
    final result = await showDialog<UserAccount>(
      context: context,
      builder: (_) => _AccountFormDialog(account: account),
    );
    if (result == null) return;
    setState(() {
      final index = _accounts.indexWhere((item) => item.id == result.id);
      if (index >= 0) {
        _accounts[index] = result;
      } else {
        _accounts.insert(0, result);
      }
    });
  }

  Future<void> _delete(UserAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: Text('Tài khoản “${account.name}” sẽ bị xóa khỏi danh sách.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _accounts.removeWhere((item) => item.id == account.id));
    }
  }

  void _changeRole(UserAccount account, UserRole role) {
    setState(() {
      final index = _accounts.indexWhere((item) => item.id == account.id);
      _accounts[index] = account.copyWith(role: role);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final search = TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Tìm tên hoặc email...',
                  prefixIcon: Icon(Icons.search),
                ),
              );
              final role = DropdownButtonFormField<UserRole?>(
                initialValue: _roleFilter,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  prefixIcon: Icon(Icons.filter_list),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tất cả vai trò'),
                  ),
                  for (final role in UserRole.values)
                    DropdownMenuItem(value: role, child: Text(role.label)),
                ],
                onChanged: (value) => setState(() => _roleFilter = value),
              );
              final add = FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Thêm tài khoản'),
              );
              if (constraints.maxWidth >= 800) {
                return Row(
                  children: [
                    Expanded(flex: 2, child: search),
                    const SizedBox(width: 12),
                    SizedBox(width: 220, child: role),
                    const SizedBox(width: 12),
                    add,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  search,
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: role),
                      const SizedBox(width: 10),
                      add,
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 850) {
                  return _AccountTable(
                    accounts: _filtered,
                    onEdit: _openForm,
                    onDelete: _delete,
                    onRoleChanged: _changeRole,
                  );
                }
                return ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final account = _filtered[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            _AccountAvatar(account: account),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    account.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  _RoleChip(role: account.role),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) => value == 'edit'
                                  ? _openForm(account)
                                  : _delete(account),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa tài khoản'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa tài khoản'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTable extends StatelessWidget {
  const _AccountTable({
    required this.accounts,
    required this.onEdit,
    required this.onDelete,
    required this.onRoleChanged,
  });
  final List<UserAccount> accounts;
  final ValueChanged<UserAccount> onEdit;
  final ValueChanged<UserAccount> onDelete;
  final void Function(UserAccount, UserRole) onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 26,
          columns: const [
            DataColumn(label: Text('Tài khoản')),
            DataColumn(label: Text('Vai trò')),
            DataColumn(label: Text('Trạng thái')),
            DataColumn(label: Text('Thao tác')),
          ],
          rows: [
            for (final account in accounts)
              DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        _AccountAvatar(account: account),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              account.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    DropdownButton<UserRole>(
                      value: account.role,
                      underline: const SizedBox(),
                      items: [
                        for (final role in UserRole.values)
                          DropdownMenuItem(
                            value: role,
                            child: _RoleChip(role: role),
                          ),
                      ],
                      onChanged: (role) {
                        if (role != null) onRoleChanged(account, role);
                      },
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 9,
                          color: account.active ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 7),
                        Text(account.active ? 'Hoạt động' : 'Đã khóa'),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => onEdit(account),
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Sửa',
                        ),
                        IconButton(
                          onPressed: () => onDelete(account),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Xóa',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.account});
  final UserAccount account;

  @override
  Widget build(BuildContext context) {
    final words = account.name.trim().split(' ');
    final initials = words.length > 1
        ? '${words[words.length - 2][0]}${words.last[0]}'
        : words.first[0];
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      UserRole.user => Colors.green,
      UserRole.staff => Colors.orange,
      UserRole.admin => Colors.purple,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AccountFormDialog extends StatefulWidget {
  const _AccountFormDialog({this.account});
  final UserAccount? account;

  @override
  State<_AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends State<_AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.account?.name,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.account?.email,
  );
  late UserRole _role = widget.account?.role ?? UserRole.user;
  late bool _active = widget.account?.active ?? true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.account == null ? 'Thêm tài khoản' : 'Sửa tài khoản'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Vui lòng nhập họ tên'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Email chưa hợp lệ'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: [
                  for (final role in UserRole.values)
                    DropdownMenuItem(value: role, child: Text(role.label)),
                ],
                onChanged: (value) =>
                    setState(() => _role = value ?? UserRole.user),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tài khoản hoạt động'),
                subtitle: Text(_active ? 'Có thể đăng nhập' : 'Tạm khóa'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                UserAccount(
                  id:
                      widget.account?.id ??
                      'u${DateTime.now().millisecondsSinceEpoch}',
                  name: _name.text.trim(),
                  email: _email.text.trim(),
                  role: _role,
                  active: _active,
                ),
              );
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
