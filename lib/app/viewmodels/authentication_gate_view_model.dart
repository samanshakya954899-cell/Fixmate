part of fixmate_app;

class AuthenticationGateViewModel extends ChangeNotifier {
  AuthenticationGateViewModel(this.configured) {
    repo = ServiceBookingRepository(configured);
    if (configured) {
      session = Supabase.instance.client.auth.currentSession;
      _authSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        session = event.session;
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

  void setLoginMode(String mode) {
    loginMode = mode;
    guestLoggedIn = true;
    notifyListeners();
  }

  void handleSignOut() {
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

