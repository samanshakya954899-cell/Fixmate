part of fixmate_app;

Future<void> _openServiceListingForm(
    BuildContext context, ServiceRepository repo) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _ServiceListingFormSheet(repo: repo),
  );
  if (saved == true && context.mounted) {
    _snack(context, 'Service saved');
  }
}

class _ServiceListingFormSheet extends StatefulWidget {
  const _ServiceListingFormSheet({required this.repo});

  final ServiceRepository repo;

  @override
  State<_ServiceListingFormSheet> createState() =>
      _ServiceListingFormSheetState();
}

class _ServiceListingFormSheetState extends State<_ServiceListingFormSheet> {
  late final ServiceListingFormViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ServiceListingFormViewModel(widget.repo);
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
      builder: (context, _) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add a service listing',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (viewModel.loading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<String>(
                  initialValue: viewModel.categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final category in viewModel.categories)
                      DropdownMenuItem(
                          value: category['id'] as String,
                          child: Text(category['name'])),
                  ],
                  onChanged:
                      viewModel.saving ? null : viewModel.selectCategory,
                ),
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 10),
                InfoBanner(
                  icon: Icons.error_outline,
                  text: viewModel.errorMessage!,
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                  controller: viewModel.title,
                  enabled: !viewModel.saving,
                  decoration:
                      const InputDecoration(labelText: 'Service title')),
              const SizedBox(height: 8),
              TextField(
                  controller: viewModel.description,
                  enabled: !viewModel.saving,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              TextField(
                controller: viewModel.charge,
                enabled: !viewModel.saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Base charge'),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: viewModel.city,
                  enabled: !viewModel.saving,
                  decoration: const InputDecoration(labelText: 'City')),
              const SizedBox(height: 8),
              TextField(
                  controller: viewModel.area,
                  enabled: !viewModel.saving,
                  decoration: const InputDecoration(labelText: 'Service area')),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: viewModel.loading || viewModel.saving
                    ? null
                    : () async {
                        final saved = await viewModel.save();
                        if (saved && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                icon: viewModel.saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(viewModel.saving ? 'Saving...' : 'Save service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


