part of fixmate_app;

class ProviderWorkspaceViewModel extends ChangeNotifier {
  ProviderWorkspaceViewModel(this._repo);

  final ServiceRepository _repo;

  bool loadingRequests = true;
  bool loadingServices = true;
  List<Map<String, dynamic>> incomingBookings = [];
  List<Map<String, dynamic>> services = [];

  Future<void> load() async {
    await Future.wait([loadRequests(), loadServices()]);
  }

  Future<void> loadRequests() async {
    loadingRequests = true;
    notifyListeners();
    incomingBookings = await _repo.providerIncomingBookings();
    loadingRequests = false;
    notifyListeners();
  }

  Future<void> loadServices() async {
    loadingServices = true;
    notifyListeners();
    final allServices = await _repo.providerServices();
    services = allServices
        .where((service) =>
            !_repo.configured || service['provider_id'] == _repo.currentUserId)
        .toList();
    loadingServices = false;
    notifyListeners();
  }

  Future<void> refresh() => load();
}

