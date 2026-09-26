import 'package:equatable/equatable.dart';

class JotformQuestion extends Equatable {
  final String id;
  final String name;
  final List<String> options;
  final List<String> subkeys;

  const JotformQuestion({required this.id, required this.name, this.options = const [], this.subkeys = const[]});

  @override
  List<Object?> get props => [id, name, options, subkeys];
}
