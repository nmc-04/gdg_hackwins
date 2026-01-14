// Stubbed AuthService - replace with FirebaseAuth later
class AuthService {
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Return true for any non-empty credentials in prototype
    return email.isNotEmpty && password.isNotEmpty;
  }

  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return name.isNotEmpty && email.isNotEmpty && password.length >= 6;
  }

  Future<void> logout() async {}
}
