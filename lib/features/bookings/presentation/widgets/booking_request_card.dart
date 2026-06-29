part of fixmate_app;

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.repo,
    required this.showProviderActions,
    required this.onChanged,
  });

  final Map<String, dynamic> booking;
  final ServiceRepository repo;
  final bool showProviderActions;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final category =
        booking['service_categories'] as Map<String, dynamic>? ?? {};
    final status = booking['status'] as String? ?? 'pending';
    final canChat = booking['provider_id'] != null &&
        status != 'pending' &&
        status != 'rejected';
    final viewModel = BookingRequestCardViewModel(repo: repo, booking: booking);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE6F6F5), Color(0xFFFFF3EF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.handyman_outlined,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'] ?? 'Service',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        booking['booking_type'] == 'open'
                            ? 'Open request'
                            : 'Direct booking',
                        style: const TextStyle(
                          color: _mutedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              booking['issue_description'] ?? '',
              style: const TextStyle(
                color: _inkColor,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            IconLine(
              icon: Icons.location_on_outlined,
              text: booking['address'] ?? '',
            ),
            if (booking['preferred_at'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: IconLine(
                  icon: Icons.schedule,
                  text: _formatDate(booking['preferred_at']),
                ),
              ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (showProviderActions && status == 'pending') ...[
                  FilledButton.icon(
                    onPressed: () async {
                      await viewModel.accept();
                      onChanged();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await viewModel.reject();
                      onChanged();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ],
                if (showProviderActions && status == 'accepted')
                  OutlinedButton.icon(
                    onPressed: () async {
                      await viewModel.start();
                      onChanged();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                if (status == 'in_progress')
                  OutlinedButton.icon(
                    onPressed: () async {
                      await viewModel.complete();
                      onChanged();
                    },
                    icon: const Icon(Icons.done_all),
                    label: const Text('Complete'),
                  ),
                if (canChat)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final chatId = await viewModel.ensureChat();
                      if (chatId != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatScreen(repo: repo, chatId: chatId),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat'),
                  ),
                if (status == 'completed')
                  OutlinedButton.icon(
                    onPressed: () =>
                        _openBookingRatingSheet(context, repo, booking),
                    icon: const Icon(Icons.star_border),
                    label: const Text('Rate'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


