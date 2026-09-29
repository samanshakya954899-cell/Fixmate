part of fixmate_app;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.repo});

  final ServiceRepository repo;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = NotificationsViewModel(widget.repo);
    Future.microtask(viewModel.load);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: AppBackdrop(
          child: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          if (viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.notifications.isEmpty) {
            return const EmptyState(text: 'There are no notifications yet.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.notifications.length,
            itemBuilder: (context, index) {
              final item = viewModel.notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: const SoftIconTile(
                    icon: Icons.notifications_active_outlined,
                    size: 44,
                  ),
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['body'] ?? ''),
                ),
              );
            },
          );
        },
      )),
    );
  }
}
