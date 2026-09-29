part of fixmate_app;

enum AuthFlowStep { email, credentials, otp }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo);

  final ServiceRepository _repo;

  final name = TextEditingController();
  final companyName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final otp = TextEditingController();

  AuthFlowStep step = AuthFlowStep.email;
  String loginMode = 'customer';
  bool accountFound = false;
  bool obscurePassword = true;
  bool busy = false;
  int resendSeconds = 0;
  Timer? _resendTimer;

  bool get isSignup => !accountFound;

  void setLoginMode(String value) {
    loginMode = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void changeEmail() {
    _resendTimer?.cancel();
    step = AuthFlowStep.email;
    accountFound = false;
    otp.clear();
    resendSeconds = 0;
    notifyListeners();
  }

  Future<AuthResult> continueWithEmail() async {
    if (busy) return const AuthResult();
    final normalizedEmail = email.text.trim().toLowerCase();
    if (!_looksLikeEmail(normalizedEmail)) {
      return const AuthResult(message: 'Enter a valid email address.');
    }
    busy = true;
    notifyListeners();
    try {
      accountFound = await _repo.accountExists(normalizedEmail);
      step = AuthFlowStep.credentials;
      return const AuthResult();
    } catch (error) {
      return AuthResult(message: _friendlyAuthError(error));
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<AuthResult> signInWithPassword() async {
    if (busy) return const AuthResult();
    if (password.text.isEmpty) {
      return const AuthResult(message: 'Enter your password.');
    }
    busy = true;
    notifyListeners();
    try {
      await _repo.signIn(email.text.trim().toLowerCase(), password.text);
      await _repo.rememberPreferredRole(loginMode);
      return AuthResult(authenticatedMode: loginMode);
    } catch (error) {
      return AuthResult(message: _friendlyAuthError(error));
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<AuthResult> sendOtp() async {
    if (busy) return const AuthResult();
    if (resendSeconds > 0) {
      return AuthResult(
        message: 'Please wait $resendSeconds seconds before resending.',
      );
    }
    if (isSignup) {
      if (name.text.trim().isEmpty) {
        return const AuthResult(message: 'Enter your full name.');
      }
      if (password.text.length < 8) {
        return const AuthResult(
          message: 'Create a password with at least 8 characters.',
        );
      }
    }
    busy = true;
    notifyListeners();
    try {
      final normalizedEmail = email.text.trim().toLowerCase();
      if (isSignup) {
        await _repo.requestSignupOtp(
          name: name.text.trim(),
          companyName: companyName.text.trim(),
          email: normalizedEmail,
          password: password.text,
          accountType: loginMode,
        );
      } else {
        await _repo.requestSignInOtp(normalizedEmail);
      }
      otp.clear();
      step = AuthFlowStep.otp;
      _startResendTimer();
      return const AuthResult(message: 'Verification code sent to your email.');
    } catch (error) {
      return AuthResult(message: _friendlyAuthError(error));
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<AuthResult> verifyOtp() async {
    if (busy) return const AuthResult();
    final code = otp.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return const AuthResult(message: 'Enter the 6-digit verification code.');
    }
    busy = true;
    notifyListeners();
    try {
      final normalizedEmail = email.text.trim().toLowerCase();
      if (isSignup) {
        await _repo.verifySignupOtp(normalizedEmail, code);
      } else {
        await _repo.verifySignInOtp(normalizedEmail, code);
        await _repo.rememberPreferredRole(loginMode);
      }
      return AuthResult(
        authenticatedMode: loginMode,
        message: isSignup
            ? 'Email verified. Your account is ready.'
            : 'Signed in successfully.',
      );
    } catch (error) {
      return AuthResult(message: _friendlyAuthError(error));
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<String?> resetPassword() async {
    if (busy) return null;
    busy = true;
    notifyListeners();
    try {
      await _repo.resetPassword(email.text.trim().toLowerCase());
      return 'Password reset email sent.';
    } catch (error) {
      return _friendlyAuthError(error);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds <= 1) {
        resendSeconds = 0;
        timer.cancel();
      } else {
        resendSeconds -= 1;
      }
      notifyListeners();
    });
  }

  bool _looksLikeEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  String _friendlyAuthError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('Invalid login credentials') ||
        message.contains('Invalid email or password')) {
      return 'Invalid email or password.';
    }
    if (message.contains('SocketException') ||
        message.contains('Failed to fetch') ||
        message.contains('TimeoutException')) {
      return 'Unable to connect to the server. Please try again.';
    }
    return message;
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    name.dispose();
    companyName.dispose();
    email.dispose();
    password.dispose();
    otp.dispose();
    super.dispose();
  }
}

class AuthResult {
  const AuthResult({this.message, this.authenticatedMode});

  final String? message;
  final String? authenticatedMode;
}
