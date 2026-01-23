import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String name;
  final String email;
  final int id;

  const User({
    required this.name,
    required this.email,
    required this.id});

  @override
  // TODO: implement props
  List<Object?> get props => [id, name, email];
}