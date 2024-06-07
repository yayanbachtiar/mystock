import 'package:pocketbase/pocketbase.dart';

class AuthRepository {
  final PocketBase pb;

  AuthRepository(this.pb);

  Future<void> signIn(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }

  Future<void> signOut() async {
    pb.authStore.clear();
  }

  bool get isAuthenticated => pb.authStore.isValid;
}
