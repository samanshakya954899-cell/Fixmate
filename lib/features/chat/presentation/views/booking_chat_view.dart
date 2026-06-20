part of fixmate_app;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.repo, required this.chatId});

  final ServiceRepository repo;
  final String chatId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final BookingChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = BookingChatViewModel(widget.repo, widget.chatId);
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
      builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Booking chat')),
      body: Column(
        children: [
          Expanded(
            child: viewModel.loading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.messages.isEmpty
                    ? const EmptyState(text: 'Send the first message.')
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.messages[index];
                    final mine = item['sender_id'] == viewModel.currentUserId;
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: mine
                              ? _primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(mine ? 18 : 4),
                            bottomRight: Radius.circular(mine ? 4 : 18),
                          ),
                          border: mine
                              ? null
                              : Border.all(color: const Color(0xFFE8EEF2)),
                        ),
                        child: Text(
                          item['body'] ?? '',
                          style: TextStyle(
                            color: mine ? Colors.white : _inkColor,
                            height: 1.35,
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE8EEF2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: viewModel.message,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        prefixIcon: Icon(Icons.chat_bubble_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () async {
                      await viewModel.send();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}


