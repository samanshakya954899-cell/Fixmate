part of fixmate_app;

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.repo,
    this.demoMode = false,
    this.mode = 'customer',
    this.initialIndex = 0,
    required this.onSignOut,
  });

  final ServiceRepository repo;
  final bool demoMode;
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
              demoMode: widget.demoMode,
              mode: widget.mode,
              onSignOut: widget.onSignOut,
            ),
          ]
        : [
            CustomerHome(repo: widget.repo),
            BookingsScreen(repo: widget.repo),
            ProfileScreen(
              repo: widget.repo,
              demoMode: widget.demoMode,
              mode: widget.mode,
              onSignOut: widget.onSignOut,
            ),
          ];
    final destinations = viewModel.providerMode
        ? const [
            NavigationDestination(
                icon: Icon(Icons.engineering), label: 'Provider'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long), label: 'Jobs'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ]
        : const [
            NavigationDestination(icon: Icon(Icons.search), label: 'Services'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long), label: 'Bookings'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_repair_service, size: 22),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                viewModel.appName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.demoMode)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                backgroundColor: Colors.white,
                label: Text('Demo'),
              ),
            ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => NotificationsScreen(repo: widget.repo)),
            ),
          ),
        ],
      ),
      body: pages[viewModel.index],
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: viewModel.index,
        onDestinationSelected: viewModel.selectIndex,
        destinations: destinations,
      ),
    );
      },
    );
  }
}


