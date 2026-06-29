part of fixmate_app;

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.repo,
    this.mode = 'customer',
    this.initialIndex = 0,
    required this.onSignOut,
  });

  final ServiceRepository repo;
  final String mode;
  final int initialIndex;
  final VoidCallback onSignOut;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final RoleBasedHomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = RoleBasedHomeViewModel(
      mode: widget.mode,
      initialIndex: widget.initialIndex,
    );
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
        final pages = viewModel.providerMode
            ? [
                ProviderHome(repo: widget.repo),
                BookingsScreen(repo: widget.repo),
                ProfileScreen(
                  repo: widget.repo,
                  mode: widget.mode,
                  onSignOut: widget.onSignOut,
                ),
              ]
            : [
                CustomerHome(repo: widget.repo),
                BookingsScreen(repo: widget.repo),
                ProfileScreen(
                  repo: widget.repo,
                  mode: widget.mode,
                  onSignOut: widget.onSignOut,
                ),
              ];
        final destinations = viewModel.providerMode
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.engineering_outlined),
                  selectedIcon: Icon(Icons.engineering),
                  label: 'Provider',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Jobs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.search),
                  label: 'Services',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Bookings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ];

        return Scaffold(
          appBar: AppBar(
            flexibleSpace: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryColor, Color(0xFF12455A)],
                ),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_repair_service, size: 23),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    viewModel.appName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  tooltip: 'Notifications',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.14),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationsScreen(repo: widget.repo),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: pages[viewModel.index],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: _surfaceColor,
              border: Border(top: BorderSide(color: Color(0xFFE4EAF0))),
              boxShadow: [
                BoxShadow(
                  color: Color(0x140E7C7B),
                  blurRadius: 18,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            child: NavigationBar(
              height: 78,
              selectedIndex: viewModel.index,
              onDestinationSelected: viewModel.selectIndex,
              destinations: destinations,
            ),
          ),
        );
      },
    );
  }
}
