import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import 'auth_remote_dataSource.dart';

final authRemoteDatasourceProvider =
Provider<AuthRemoteDatasource>((ref) {
  final dio = ref.read(dioProvider);
  return AuthRemoteDatasource(dio);
});