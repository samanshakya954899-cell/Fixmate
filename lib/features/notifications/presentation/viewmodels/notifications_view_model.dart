part of fixmate_app;

class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel(this._repo);

  final ServiceRepository _repo;

  bool loading = true;
  List<Map<String, dynamic>> notifications = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();
    notifications = await _repo.notifications();
    loading = false;
    notifyListeners();
  }
}

