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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
          children: [
            const AppHero(
              icon: Icons.engineering_outlined,
              title: 'Provider workspace',
              subtitle:
                  'Manage customer requests and publish your service listings.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await _openServiceListingForm(context, widget.repo);
                if (mounted) await viewModel.loadServices();
              },
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
            else if (viewModel.requestsErrorMessage != null)
              _WorkspaceLoadError(
                message: viewModel.requestsErrorMessage!,
                onRetry: viewModel.loadRequests,
              )
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
            else if (viewModel.servicesErrorMessage != null)
              _WorkspaceLoadError(
                message: viewModel.servicesErrorMessage!,
                onRetry: viewModel.loadServices,
              )
            else if (viewModel.services.isEmpty)
              const EmptyState(
                  text:
                      'Your service listings will appear here after you add them.')
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

class _WorkspaceLoadError extends StatelessWidget {
  const _WorkspaceLoadError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: _mutedColor,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _mutedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
