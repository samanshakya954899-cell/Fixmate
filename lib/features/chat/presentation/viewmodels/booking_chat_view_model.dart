part of fixmate_app;

class BookingChatViewModel extends ChangeNotifier {
  BookingChatViewModel(this._repo, this.chatId);

  final ServiceRepository _repo;
  final String chatId;
  final message = TextEditingController();

  bool loading = true;
  List<Map<String, dynamic>> messages = [];

  String get currentUserId => _repo.currentUserId;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    messages = await _repo.messages(chatId);
    loading = false;
    notifyListeners();
  }

  Future<void> send() async {
    final body = message.text.trim();
    if (body.isEmpty) return;
    await _repo.sendMessage(chatId, body);
    message.clear();
    await load();
  }

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }
}

