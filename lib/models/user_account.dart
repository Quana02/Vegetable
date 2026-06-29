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

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
    id: json['id'].toString(),
    name: json['fullName'] as String,
    email: json['email'] as String,
    role: UserRole.values.firstWhere(
      (role) => role.name == (json['role'] as String).toLowerCase(),
      orElse: () => UserRole.user,
    ),
    active: json['isActive'] as bool? ?? true,
  );

  int get numericId => int.parse(id);

  int get roleId => switch (role) {
    UserRole.user => 1,
    UserRole.staff => 2,
    UserRole.admin => 3,
  };

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
