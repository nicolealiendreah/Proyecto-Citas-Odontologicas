import '../models/fake_user.dart';

class FakeAuthService {
  FakeAuthService._internal();

  static final FakeAuthService instance = FakeAuthService._internal();

  FakeUser? _registeredUser;
  FakeUser? _currentUser;

  FakeUser? get currentUser => _currentUser;

  bool register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) {
    _registeredUser = FakeUser(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
    );
    return true;
  }

  bool login({
    required String email,
    required String password,
  }) {
    if (_registeredUser == null) return false;

    if (_registeredUser!.email == email &&
        _registeredUser!.password == password) {
      _currentUser = _registeredUser;
      return true;
    }

    return false;
  }

  void logout() {
    _currentUser = null;
  }
}