enum BusinessRole{
  owner,
  admin,
  photographer,
  assistant;

  String get value {
    switch (this) {
      case BusinessRole.owner:
        return 'owner';
      case BusinessRole.admin:
        return 'admin';
      case BusinessRole.photographer:
        return 'photographer';
      case BusinessRole.assistant:
        return 'assistant';
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
      case 'assistant':
        return BusinessRole.assistant;
      default:
        throw ArgumentError('Invalid role: $role');
    }
  }
}