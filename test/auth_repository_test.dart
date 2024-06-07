import 'package:flutter_test/flutter_test.dart';
import 'package:mystok/data/repositories/auth_repository.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  final pb = PocketBase('http://10.0.0.102:8080');
  final authRepository = AuthRepository(pb);

  test('signIn should work', () async {
    expect(
        () async => await authRepository.signIn('test@example.com', 'password'),
        returnsNormally);
  });

  test('signOut should work', () async {
    expect(() async => await authRepository.signOut(), returnsNormally);
  });
}
