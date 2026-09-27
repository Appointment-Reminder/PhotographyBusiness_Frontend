import 'package:flutter/material.dart';

/// Deterministic color per photographer, keyed by `member_id`.
/// Assumed to be BusinessMember.id (matches how commissions/jotform
/// assignments key their `business_member_id`) — flip to `user_id` here if
/// that assumption turns out wrong.
class PhotographerColors {
  PhotographerColors._();

  static const _palette = [
    Colors.blue,
    Colors.green,
    Colors.deepPurple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
  ];

  static const unassigned = Colors.grey;

  static Color of(int? memberId) {
    if (memberId == null) return unassigned;
    return _palette[memberId % _palette.length];
  }
}
