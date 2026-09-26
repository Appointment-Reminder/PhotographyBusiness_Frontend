import 'package:equatable/equatable.dart';

class QuestionSelection extends Equatable {
  final String qid;
  final String? subkey;
  const QuestionSelection(this.qid, {this.subkey});
  
  QuestionSelection copyWithSubkey(String? subkey) => QuestionSelection(qid, subkey: subkey);

  @override
  List<Object?> get props => [qid, subkey];
}