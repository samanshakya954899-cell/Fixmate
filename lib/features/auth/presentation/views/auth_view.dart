part of fixmate_app;

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.repo,
    required this.onAuthenticated,
  });

  final ServiceRepository repo;
  final FutureOr<void> Function(String mode) onAuthenticated;

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

  Future<void> run(Future<AuthResult> Function() action) async {
    final result = await action();
    if (!mounted) return;
    if (result.message != null) _snack(context, result.message!);
    if (result.authenticatedMode != null) {
      await widget.onAuthenticated(result.authenticatedMode!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF171B43),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final phoneLayout = constraints.maxWidth < 560;
            final shellRadius =
                phoneLayout ? BorderRadius.zero : BorderRadius.circular(34);
            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF171B43), Color(0xFF5B5CE2)],
                ),
              ),
              child: Center(
                child: Container(
                  width: phoneLayout ? constraints.maxWidth : 460,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FF),
                    borderRadius: shellRadius,
                    boxShadow: phoneLayout
                        ? const []
                        : const [
                            BoxShadow(
                              color: Color(0x590D123C),
                              blurRadius: 42,
                              offset: Offset(0, 18),
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: shellRadius,
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _authHero(),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(22, 16, 22, 16),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFF6F8FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(30),
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 260),
                                layoutBuilder:
                                    (currentChild, previousChildren) => Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                ),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(.04, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                                child: KeyedSubtree(
                                  key: ValueKey(viewModel.step),
                                  child: viewModel.step == AuthFlowStep.email
                                      ? _emailStep()
                                      : viewModel.step ==
                                              AuthFlowStep.credentials
                                          ? _credentialsStep()
                                          : _otpStep(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _authHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C48E8), Color(0xFF715EEB)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -44,
            top: -55,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1AFFFFFF),
              ),
            ),
          ),
          Positioned(
            left: -68,
            bottom: -95,
            child: Container(
              width: 210,
              height: 210,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1424D7E7),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBrand(),
                const SizedBox(height: 12),
                _stepProgress(),
                const SizedBox(height: 16),
                _header(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBrand() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0x24FFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x38FFFFFF)),
          ),
          child: const Icon(
            Icons.home_repair_service_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FixMate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Your trusted service partner',
                style: TextStyle(color: Color(0xC9FFFFFF), fontSize: 11.5),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x24FFFFFF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x2EFFFFFF)),
          ),
          child: Text(
            'Step ${AuthFlowStep.values.indexOf(viewModel.step) + 1} of 3',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepProgress() {
    final currentStep = AuthFlowStep.values.indexOf(viewModel.step);
    final labels = viewModel.accountFound
        ? const ['Email', 'Sign in', 'Verify']
        : const ['Email', 'Account', 'Verify'];
    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 5,
                  decoration: BoxDecoration(
                    color: index <= currentStep
                        ? Colors.white
                        : const Color(0x52FFFFFF),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  labels[index],
                  style: TextStyle(
                    color: index <= currentStep
                        ? Colors.white
                        : const Color(0xA8FFFFFF),
                    fontWeight: index == currentStep
                        ? FontWeight.w800
                        : FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (index < labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _header() {
    final (title, subtitle, icon) = switch (viewModel.step) {
      AuthFlowStep.email => (
          'Welcome to FixMate',
          'Enter your email address to continue.',
          Icons.home_repair_service_rounded,
        ),
      AuthFlowStep.credentials when viewModel.accountFound => (
          'Welcome back',
          'Enter your password or use a one-time code.',
          Icons.lock_open_rounded,
        ),
      AuthFlowStep.credentials => (
          'Create your account',
          'Add your details, then verify your email.',
          Icons.person_add_alt_1_rounded,
        ),
      AuthFlowStep.otp => (
          'Check your inbox',
          'Enter the 6-digit code sent to your email.',
          Icons.mark_email_read_rounded,
        ),
    };
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0x24FFFFFF),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0x38FFFFFF)),
          ),
          child: Icon(icon, size: 27, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xD9FFFFFF),
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeading(
          'LET’S GET STARTED',
          'Use your email to sign in or create a new FixMate account.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: viewModel.email,
          enabled: !viewModel.busy,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => run(viewModel.continueWithEmail),
          decoration: const InputDecoration(
            labelText: 'Email address',
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
        ),
        const SizedBox(height: 22),
        _AuthPrimaryButton(
          label: 'Continue',
          icon: Icons.login_rounded,
          busy: viewModel.busy,
          onPressed: () => run(viewModel.continueWithEmail),
        ),
        const SizedBox(height: 12),
        _infoPanel(
          Icons.shield_outlined,
          'Secure sign in',
          'New accounts are protected with email OTP verification.',
        ),
        const SizedBox(height: 18),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded, size: 15, color: Color(0xFF16A6B7)),
            SizedBox(width: 6),
            Text(
              'Fast  •  Safe  •  Hassle-free',
              style: TextStyle(
                color: _mutedColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (MediaQuery.sizeOf(context).height >= 650) ...[
          const Spacer(),
          _authFooter('Private and protected access'),
        ],
      ],
    );
  }

  Widget _credentialsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _emailSummary(),
        const SizedBox(height: 14),
        if (!viewModel.accountFound) ...[
          _roleSelector(),
          const SizedBox(height: 14),
          TextField(
            controller: viewModel.name,
            enabled: !viewModel.busy,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(
              labelText: 'Full name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          if (viewModel.loginMode == 'provider') ...[
            const SizedBox(height: 8),
            TextField(
              controller: viewModel.companyName,
              enabled: !viewModel.busy,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Shop / service business name (optional)',
                hintText: 'Example: Kumar AC Repair',
                prefixIcon: Icon(Icons.home_repair_service_outlined),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ] else ...[
          _roleSelector(),
          const SizedBox(height: 14),
          const Text(
            'PASSWORD',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.15,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: viewModel.password,
          enabled: !viewModel.busy,
          obscureText: viewModel.obscurePassword,
          autofillHints: viewModel.accountFound
              ? const [AutofillHints.password]
              : const [AutofillHints.newPassword],
          onSubmitted: viewModel.accountFound
              ? (_) => run(viewModel.signInWithPassword)
              : null,
          decoration: InputDecoration(
            labelText: viewModel.accountFound ? 'Password' : 'Create password',
            hintText: viewModel.accountFound
                ? 'Enter your password'
                : 'At least 8 characters',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: TextButton(
              onPressed: viewModel.togglePasswordVisibility,
              child: Text(viewModel.obscurePassword ? 'Show' : 'Hide'),
            ),
          ),
        ),
        const SizedBox(height: 7),
        if (!viewModel.accountFound) ...[
          const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 17,
                color: Color(0xFF16A6B7),
              ),
              SizedBox(width: 7),
              Text(
                'Use 8 or more characters',
                style: TextStyle(
                  color: _mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (viewModel.accountFound)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: viewModel.busy ? null : () => run(viewModel.sendOtp),
                child: const Text('Login with OTP'),
              ),
              TextButton(
                onPressed: viewModel.busy
                    ? null
                    : () async {
                        final message = await viewModel.resetPassword();
                        if (mounted && message != null)
                          _snack(context, message);
                      },
                child: const Text('Forgot password?'),
              ),
            ],
          )
        else
          const SizedBox(height: 6),
        _AuthPrimaryButton(
          label: viewModel.accountFound ? 'Sign in' : 'Send verification code',
          icon: viewModel.accountFound
              ? Icons.login_rounded
              : Icons.mark_email_unread_outlined,
          busy: viewModel.busy,
          onPressed: () => run(
            viewModel.accountFound
                ? viewModel.signInWithPassword
                : viewModel.sendOtp,
          ),
        ),
        if (MediaQuery.sizeOf(context).height >= 650) ...[
          const Spacer(),
          _authFooter(
            viewModel.accountFound
                ? 'Secure password authentication'
                : 'Your email will be verified before signup',
          ),
        ],
      ],
    );
  }

  Widget _otpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _emailSummary(),
        const SizedBox(height: 18),
        _infoPanel(
          Icons.schedule_rounded,
          'Code expires soon',
          'For your security, the 6-digit code is valid for 10 minutes.',
        ),
        const SizedBox(height: 22),
        _sectionHeading(
          'VERIFICATION CODE',
          'Type the code from your FixMate email below.',
        ),
        const SizedBox(height: 14),
        TextField(
          controller: viewModel.otp,
          enabled: !viewModel.busy,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 12,
            color: _navyColor,
          ),
          onSubmitted: (_) => run(viewModel.verifyOtp),
          decoration: const InputDecoration(
            labelText: 'Verification code',
            hintText: '000000',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        _AuthPrimaryButton(
          label: 'Verify & continue',
          icon: Icons.verified_user_outlined,
          busy: viewModel.busy,
          onPressed: () => run(viewModel.verifyOtp),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE3E8F4)),
          ),
          child: TextButton.icon(
            onPressed: viewModel.busy || viewModel.resendSeconds > 0
                ? null
                : () => run(viewModel.sendOtp),
            icon: const Icon(Icons.refresh_rounded, size: 19),
            label: Text(
              viewModel.resendSeconds > 0
                  ? 'Resend available in ${viewModel.resendSeconds}s'
                  : 'Resend verification code',
            ),
          ),
        ),
        if (MediaQuery.sizeOf(context).height >= 650) ...[
          const Spacer(),
          _authFooter('Never share your verification code'),
        ],
      ],
    );
  }

  Widget _emailSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD9E5FA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: Color(0xFF16A6B7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              viewModel.email.text.trim(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _navyColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: viewModel.busy ? null : viewModel.changeEmail,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _primaryColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.15,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _mutedColor,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _infoPanel(IconData icon, String title, String message) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE6FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: _primaryColor),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _navyColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: _mutedColor,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _authFooter(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_rounded,
            size: 13,
            color: Color(0xFF98A2BA),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF98A2BA),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Continue as', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: _RoleLoginOption(
                selected: viewModel.loginMode == 'customer',
                icon: Icons.person_rounded,
                title: 'Customer',
                subtitle: 'Book services',
                color: _primaryColor,
                onTap: viewModel.busy
                    ? null
                    : () => viewModel.setLoginMode('customer'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _RoleLoginOption(
                selected: viewModel.loginMode == 'provider',
                icon: Icons.handyman_rounded,
                title: 'Provider',
                subtitle: 'Offer services',
                color: _providerColor,
                onTap: viewModel.busy
                    ? null
                    : () => viewModel.setLoginMode('provider'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthPrimaryButton extends StatelessWidget {
  const _AuthPrimaryButton({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: busy ? .7 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: busy ? null : onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C50FF), Color(0xFF28C2DC)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x403B73FF),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  busy ? 'Please wait...' : label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleLoginOption extends StatelessWidget {
  const _RoleLoginOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Continue as $title',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: .09) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? color : const Color(0xFFE2E5EF),
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: Colors.white, size: 19),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _inkColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style:
                            const TextStyle(color: _mutedColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: color, size: 17),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
