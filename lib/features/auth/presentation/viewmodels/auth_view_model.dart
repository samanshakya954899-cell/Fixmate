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
  DateTime? _emailRetryAt;

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
    final waitMessage = _emailRateLimitMessage();
    if (waitMessage != null && signup) {
      return AuthResult(message: waitMessage);
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
        await _repo.signIn(email.text.trim(), password.text);
        return AuthResult(
          authenticatedMode: loginMode,
          message: 'Account created successfully.',
        );
      }
      await _repo.signIn(email.text.trim(), password.text);
      return AuthResult(authenticatedMode: loginMode);
    } catch (e) {
      return AuthResult(message: _friendlyAuthError(e));
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<String?> resetPassword() async {
    if (email.text.trim().isEmpty) {
      return 'Enter your email to reset your password.';
    }
    final waitMessage = _emailRateLimitMessage();
    if (waitMessage != null) return waitMessage;
    try {
      await _repo.resetPassword(email.text.trim());
      return 'Password reset email sent.';
    } catch (e) {
      return _friendlyAuthError(e);
    }
  }

  String? _emailRateLimitMessage() {
    final retryAt = _emailRetryAt;
    if (retryAt == null) return null;
    final wait = retryAt.difference(DateTime.now());
    if (wait.isNegative) {
      _emailRetryAt = null;
      return null;
    }
    final minutes = wait.inMinutes + 1;
    return 'Too many emails were requested. Please wait about $minutes minute${minutes == 1 ? '' : 's'} and try again.';
  }

  String _friendlyAuthError(Object error) {
    final message = error.toString();
    if (message.contains('over_email_send_rate_limit') ||
        message.contains('email rate limit exceeded') ||
        message.contains('statusCode: 429')) {
      _emailRetryAt = DateTime.now().add(const Duration(minutes: 10));
      return 'Supabase has temporarily blocked more auth emails for this project. Please wait a few minutes, then try again.';
    }
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (message.contains('User already registered')) {
      return 'This email is already registered. Log in instead.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Account created, but Supabase email confirmation is enabled. Confirm your email or turn off email confirmation for testing.';
    }
    return message.replaceFirst('Exception: ', '');
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

