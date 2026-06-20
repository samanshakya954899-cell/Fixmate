part of fixmate_app;

class ProviderHome extends StatefulWidget {
  const ProviderHome({super.key, required this.repo});

  final ServiceRepository repo;

  @override
  State<ProviderHome> createState() => _ProviderHomeState();
}

class _ProviderHomeState extends State<ProviderHome> {
  late final ProviderWorkspaceViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ProviderWorkspaceViewModel(widget.repo);
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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AppHero(
            icon: Icons.engineering_outlined,
            title: 'Provider workspace',
            subtitle:
                'Manage customer requests and publish your service listings.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _openServiceListingForm(context, widget.repo)
                .then((_) => viewModel.loadServices()),
            icon: const Icon(Icons.add_business),
            label: const Text('Add a service listing'),
          ),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'Incoming requests',
            subtitle: 'New customer jobs',
          ),
          const SizedBox(height: 10),
          if (viewModel.loadingRequests)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.incomingBookings.isEmpty)
            const EmptyState(text: 'There are no requests yet.')
          else
            Column(
              children: [
                for (final booking in viewModel.incomingBookings)
                  BookingCard(
                    booking: booking,
                    repo: widget.repo,
                    showProviderActions: true,
                    onChanged: viewModel.loadRequests,
                  ),
              ],
            ),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'My services',
            subtitle: 'Active listings',
          ),
          const SizedBox(height: 10),
          if (viewModel.loadingServices)
            const LinearProgressIndicator()
          else if (viewModel.services.isEmpty)
            const EmptyState(
                text: 'Your service listings will appear here after you add them.')
          else
            Column(
              children: [
                for (final service in viewModel.services)
                  ServiceListingCard(service: service, onBook: () {}),
              ],
            ),
        ],
      ),
      ),
    );
  }
}


