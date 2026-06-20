part of fixmate_app;

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo);

  final ServiceRepository _repo;

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  String loginMode = 'customer';
  bool signup = false;
  bool busy = false;

  void setLoginMode(String value) {
    loginMode = value;
    notifyListeners();
  }

  void toggleSignup() {
    signup = !signup;
    notifyListeners();
  }

  Future<AuthResult> submit() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      return const AuthResult(message: 'Enter your email and password.');
    }
    if (signup && name.text.trim().isEmpty) {
      return const AuthResult(message: 'Enter your full name.');
    }

    busy = true;
    notifyListeners();
    try {
      if (!_repo.configured) {
        return AuthResult(authenticatedMode: loginMode);
      }
      if (signup) {
        await _repo.signUp(
          name.text.trim(),
          email.text.trim(),
          password.text,
          loginMode,
        );
        return const AuthResult(
          message: 'Account created. Confirm your email, then log in.',
        );
      }
      await _repo.signIn(email.text.trim(), password.text);
      return AuthResult(authenticatedMode: loginMode);
    } catch (e) {
      return AuthResult(message: e.toString());
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<String?> resetPassword() async {
    if (email.text.trim().isEmpty) {
      return 'Enter your email to reset your password.';
    }
    await _repo.resetPassword(email.text.trim());
    return 'Password reset email sent.';
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }
}

class AuthResult {
  const AuthResult({this.message, this.authenticatedMode});

  final String? message;
  final String? authenticatedMode;
}

