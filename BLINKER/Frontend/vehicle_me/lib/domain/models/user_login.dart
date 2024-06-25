// Defines a class for auth verification for users who have an account

class UserLogin {
  final String email;
  final String password;
  bool? isActive;

  UserLogin({
    required this.email,
    required this.password,
    this.isActive,
  });

  // Named constructor for creating an empty object
  UserLogin.empty()
      : email = '',
        password = '',
        isActive = true;

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      email: json['email'],
      password: json['password'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'is_active': isActive,
  };
}
