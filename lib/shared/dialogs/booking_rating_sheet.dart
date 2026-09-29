part of fixmate_app;

Future<void> _openBookingRatingSheet(
  BuildContext context,
  ServiceRepository repo,
  Map<String, dynamic> booking,
) async {
  final viewModel = BookingRatingViewModel(repo: repo, booking: booking);
  await showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFFF9F9FF),
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Rate provider',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 4, label: Text('4')),
                ButtonSegment(value: 5, label: Text('5')),
              ],
              selected: {viewModel.stars},
              onSelectionChanged: (value) => viewModel.setStars(value.first),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: viewModel.review,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Review',
                prefixIcon: Icon(Icons.rate_review_outlined),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                await viewModel.submit();
                if (context.mounted) {
                  Navigator.pop(context);
                  _snack(context, 'Rating saved');
                }
              },
              icon: const Icon(Icons.star),
              label: const Text('Submit rating'),
            ),
          ],
        ),
      ),
    ),
  ).whenComplete(viewModel.dispose);
}
