class FakeUser {
  final String fullName;
  final String phone;
  final String email;
  final String password;

  const FakeUser({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
  });

  String get firstName => fullName.trim().split(' ').first;
}
