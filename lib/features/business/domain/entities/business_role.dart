enum BusinessRole{
  owner,
  admin,
  photographer;

  String get value {
    switch (this) {
      case BusinessRole.owner:
        return 'owner';
      case BusinessRole.admin:
        return 'admin';
      case BusinessRole.photographer:
        return 'photographer';
    }
  }

  static BusinessRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return BusinessRole.owner;
      case 'admin':
        return BusinessRole.admin;
      case 'photographer':
        return BusinessRole.photographer;
      default:
        throw ArgumentError('Invalid role: $role');
    }
  }
}