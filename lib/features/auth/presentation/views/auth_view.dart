part of fixmate_app;

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.repo,
    required this.onAuthenticated,
  });

  final ServiceRepository repo;
  final ValueChanged<String> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final AuthViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AuthViewModel(widget.repo);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final result = await viewModel.submit();
    if (!mounted) return;
    if (result.message != null) _snack(context, result.message!);
    if (result.authenticatedMode != null) {
      widget.onAuthenticated(result.authenticatedMode!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) => Scaffold(
        body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E7C7B), Color(0xFF173A4A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 34,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF5F4),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.home_repair_service,
                              size: 32,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  viewModel.signup
                                      ? 'Create a new account'
                                      : 'FixSeva login',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Fast repair booking for customers and providers.',
                                  style: TextStyle(color: _mutedColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'customer',
                            icon: Icon(Icons.person_search),
                            label: Text('Customer'),
                          ),
                          ButtonSegment(
                            value: 'provider',
                            icon: Icon(Icons.engineering),
                            label: Text('Provider'),
                          ),
                        ],
                        selected: {viewModel.loginMode},
                        onSelectionChanged: viewModel.busy
                            ? null
                            : (value) => viewModel.setLoginMode(value.first),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3EF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              viewModel.loginMode == 'provider'
                                  ? Icons.add_business
                                  : Icons.search,
                              color: _accentColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                viewModel.loginMode == 'provider'
                                    ? 'Provider mode lets you manage service requests and listings.'
                                    : 'Customer mode lets you browse services and book repairs.',
                                style: const TextStyle(
                                  color: _inkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (viewModel.signup) ...[
                        TextField(
                          controller: viewModel.name,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: viewModel.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email ID',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: viewModel.password,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: viewModel.busy ? null : submit,
                        icon: viewModel.busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.login),
                        label: Text(viewModel.signup
                            ? 'Signup as ${_modeLabel(viewModel.loginMode)}'
                            : 'Login as ${_modeLabel(viewModel.loginMode)}'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed:
                            viewModel.busy ? null : viewModel.toggleSignup,
                        child: Text(viewModel.signup
                            ? 'Already have an account? Log in'
                            : 'Create a new account'),
                      ),
                      TextButton(
                        onPressed: viewModel.busy
                            ? null
                            : () async {
                                final message =
                                    await viewModel.resetPassword();
                                if (!context.mounted) return;
                                if (message != null) _snack(context, message);
                              },
                        child: const Text('Forgot password'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}


