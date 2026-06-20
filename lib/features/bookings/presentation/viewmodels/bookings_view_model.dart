part of fixmate_app;

class BookingsViewModel extends ChangeNotifier {
  BookingsViewModel(this._repo);

  final ServiceRepository _repo;

  bool loading = true;
  List<Map<String, dynamic>> bookings = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();
    bookings = await _repo.bookings();
    loading = false;
    notifyListeners();
  }

  Future<void> refresh() => load();
}

