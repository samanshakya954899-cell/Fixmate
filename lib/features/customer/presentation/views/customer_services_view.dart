part of fixmate_app;

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key, required this.repo});

  final ServiceRepository repo;

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  late final CustomerServicesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CustomerServicesViewModel(widget.repo);
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
            icon: Icons.build_circle_outlined,
            title: 'Choose a service',
            subtitle:
                'Book nearby verified providers directly or post an open request.',
          ),
          const SizedBox(height: 18),
          const SectionTitle(
            title: 'Categories',
            subtitle: 'Select a repair type',
          ),
          const SizedBox(height: 10),
          if (viewModel.loading && viewModel.categories.isEmpty)
            const LinearProgressIndicator()
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in viewModel.categories)
                  ChoiceChip(
                    avatar: Icon(_iconFor(category['icon_name']), size: 18),
                    label: Text(category['name']),
                    selected: viewModel.categoryId == category['id'],
                    onSelected: (_) =>
                        viewModel.selectCategory(category['id'] as String),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: viewModel.categoryId == null
                ? null
                : () => _openBookingRequestForm(context, widget.repo, viewModel.categoryId!,
                    type: 'open'),
            icon: const Icon(Icons.campaign),
            label: const Text('Post an open request'),
          ),
          const SizedBox(height: 18),
          const SectionTitle(
            title: 'Available providers',
            subtitle: 'Best matching services',
          ),
          const SizedBox(height: 10),
          if (viewModel.loading && viewModel.services.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.services.isEmpty)
            const EmptyState(
                text: 'No providers are available in this category yet.')
          else
            Column(
              children: [
                for (final service in viewModel.services)
                  ServiceListingCard(
                    service: service,
                    onBook: () => _openBookingRequestForm(
                      context,
                      widget.repo,
                      service['category_id'] as String,
                      type: 'direct',
                      service: service,
                    ),
                  ),
              ],
            ),
        ],
      ),
      ),
    );
  }
}


