part of fixmate_app;

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key, required this.repo});

  final ServiceRepository repo;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late final BookingsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = BookingsViewModel(widget.repo);
    Future.microtask(viewModel.load);
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
      builder: (context, _) => RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: viewModel.loading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.bookings.isEmpty
                ? const EmptyState(text: 'Your bookings will appear here.')
                : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const AppHero(
                icon: Icons.receipt_long_outlined,
                title: 'Bookings',
                subtitle:
                    'Manage service request status, chat, and ratings here.',
              ),
              const SizedBox(height: 16),
              for (final booking in viewModel.bookings)
                BookingCard(
                  booking: booking,
                  repo: widget.repo,
                  showProviderActions: false,
                  onChanged: viewModel.load,
                ),
            ],
          ),
      ),
    );
  }
}


