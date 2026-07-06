part of fixmate_app;

class AuthenticationGateViewModel extends ChangeNotifier {
  AuthenticationGateViewModel(this.configured) {
    repo = _backendUrl.isNotEmpty
        ? BackendServiceBookingRepository(_backendUrl)
        : ServiceBookingRepository(configured);
    if (_usesSupabase) {
      session = Supabase.instance.client.auth.currentSession;
      loginMode = repo.preferredRole;
      _authSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        session = event.session;
        loginMode = repo.preferredRole;
        notifyListeners();
      });
    }
  }

  final bool configured;
  late final ServiceRepository repo;
  StreamSubscription<AuthState>? _authSubscription;

  Session? session;
  String loginMode = 'customer';
  bool guestLoggedIn = false;

  int get initialIndex => 0;
  bool get _usesSupabase => _backendUrl.isEmpty && configured;
  bool get authenticated => !configured || guestLoggedIn || session != null;

  void setLoginMode(String mode) {
    loginMode = mode;
    guestLoggedIn = true;
    unawaited(repo.rememberPreferredRole(mode).catchError((_) {}));
    notifyListeners();
  }

  void handleSignOut() {
    unawaited(repo.signOut().catchError((_) {}));
    loginMode = 'customer';
    guestLoggedIn = false;
    session = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

