import 'package:equatable/equatable.dart';

import 'user.dart';

class AuthResult extends Equatable{
  final User user;
  final String token;

  const AuthResult({
    required this.user,
    required this.token,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [token, user];

}