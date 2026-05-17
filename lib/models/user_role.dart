enum UserRole { coach, client }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.coach:
        return 'Coach';
      case UserRole.client:
        return 'Client';
    }
  }

  String get accountLabel => '$label Account';
}

UserRole userRoleFromName(String? value) {
  return UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.coach,
  );
}
