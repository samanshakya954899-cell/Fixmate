part of fixmate_app;

Future<void> _openServiceListingForm(
    BuildContext context, ServiceRepository repo) async {
  final viewModel = ServiceListingFormViewModel(repo);
  await viewModel.load();
  if (!context.mounted) {
    viewModel.dispose();
    return;
  }
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => AnimatedBuilder(
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
              DropdownButtonFormField<String>(
                initialValue: viewModel.categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final category in viewModel.categories)
                    DropdownMenuItem(
                        value: category['id'] as String,
                        child: Text(category['name'])),
                ],
                onChanged: viewModel.selectCategory,
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: viewModel.title,
                  decoration:
                      const InputDecoration(labelText: 'Service title')),
              const SizedBox(height: 8),
              TextField(
                  controller: viewModel.description,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              TextField(
                controller: viewModel.charge,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Base charge'),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: viewModel.city,
                  decoration: const InputDecoration(labelText: 'City')),
              const SizedBox(height: 8),
              TextField(
                  controller: viewModel.area,
                  decoration: const InputDecoration(labelText: 'Service area')),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  await viewModel.save();
                  if (context.mounted) {
                    Navigator.pop(context);
                    _snack(context, 'Service saved');
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save service'),
              ),
            ],
          ),
        ),
      ),
    ),
  ).whenComplete(viewModel.dispose);
}


