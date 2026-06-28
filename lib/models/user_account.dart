enum UserRole { user, staff, admin }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.user => 'Người dùng',
    UserRole.staff => 'Nhân viên',
    UserRole.admin => 'Quản trị viên',
  };
}

class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.active = true,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool active;

  UserAccount copyWith({
    String? name,
    String? email,
    UserRole? role,
    bool? active,
  }) {
    return UserAccount(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      active: active ?? this.active,
    );
  }
}
