part of fixmate_app;

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.configured});

  final bool configured;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthenticationGateViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AuthenticationGateViewModel(widget.configured);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
    if (!viewModel.configured && !viewModel.demoLoggedIn) {
      return AuthScreen(
        repo: viewModel.repo,
        onAuthenticated: viewModel.setLoginMode,
      );
    }
    if (!viewModel.configured) {
      return HomeShell(
        repo: viewModel.repo,
        demoMode: true,
        mode: viewModel.loginMode,
        initialIndex: viewModel.initialIndex,
        onSignOut: viewModel.handleSignOut,
      );
    }
    if (viewModel.session == null) {
      return AuthScreen(
        repo: viewModel.repo,
        onAuthenticated: viewModel.setLoginMode,
      );
    }
    return HomeShell(
      repo: viewModel.repo,
      mode: viewModel.loginMode,
      initialIndex: viewModel.initialIndex,
      onSignOut: viewModel.handleSignOut,
    );
      },
    );
  }
}


