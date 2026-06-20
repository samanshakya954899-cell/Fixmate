part of fixmate_app;

Future<void> _openBookingRequestForm(
  BuildContext context,
  ServiceRepository repo,
  String categoryId, {
  required String type,
  Map<String, dynamic>? service,
}) {
  final viewModel = BookingRequestFormViewModel(
    repo: repo,
    categoryId: categoryId,
    type: type,
    service: service,
  );
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
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
            Text(
              type == 'direct' ? 'Direct booking' : 'Open request',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
                controller: viewModel.issue,
                decoration: const InputDecoration(
                    labelText: 'Describe the problem')),
            const SizedBox(height: 8),
            TextField(
                controller: viewModel.address,
                decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 8),
            TextField(
                controller: viewModel.city,
                decoration: const InputDecoration(labelText: 'City')),
            const SizedBox(height: 8),
            TextField(
              controller: viewModel.preferred,
              readOnly: true,
              decoration:
                  const InputDecoration(labelText: 'Preferred date/time'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 45)),
                  initialDate: DateTime.now(),
                );
                if (date == null || !context.mounted) return;
                final time = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                if (time == null) return;
                viewModel.preferred.text = DateTime(
                        date.year, date.month, date.day, time.hour, time.minute)
                    .toIso8601String();
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                final error = await viewModel.submit();
                if (error != null) {
                  _snack(context, error);
                  return;
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _snack(context, 'Booking request submitted.');
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit request'),
            ),
          ],
        ),
      ),
    ),
  ).whenComplete(viewModel.dispose);
}


