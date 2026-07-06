part of fixmate_app;

class ProviderWorkspaceViewModel extends ChangeNotifier {
  ProviderWorkspaceViewModel(this._repo);

  final ServiceRepository _repo;

  bool loadingRequests = true;
  bool loadingServices = true;
  String? requestsErrorMessage;
  String? servicesErrorMessage;
  List<Map<String, dynamic>> incomingBookings = [];
  List<Map<String, dynamic>> services = [];

  Future<void> load() async {
    await Future.wait([loadRequests(), loadServices()]);
  }

  Future<void> loadRequests() async {
    loadingRequests = true;
    requestsErrorMessage = null;
    notifyListeners();
    try {
      incomingBookings = await _repo.providerIncomingBookings();
    } catch (e) {
      incomingBookings = [];
      requestsErrorMessage = _friendlyWorkspaceError(e, 'requests');
    } finally {
      loadingRequests = false;
      notifyListeners();
    }
  }

  Future<void> loadServices() async {
    loadingServices = true;
    servicesErrorMessage = null;
    notifyListeners();
    try {
      final allServices = await _repo.providerServices();
      services = allServices
          .where((service) =>
              !_repo.configured || service['provider_id'] == _repo.currentUserId)
          .toList();
    } catch (e) {
      services = [];
      servicesErrorMessage = _friendlyWorkspaceError(e, 'services');
    } finally {
      loadingServices = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  String _friendlyWorkspaceError(Object error, String area) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('Backend tables are missing') ||
        message.contains('PGRST205') ||
        message.contains('schema cache') ||
        message.contains('Could not find the table')) {
      return 'Backend tables are missing. Run supabase/fixmate_setup.sql in Supabase, then refresh $area.';
    }
    if (message.contains('SocketException') ||
        message.contains('Failed host lookup') ||
        message.contains('TimeoutException') ||
        message.contains('Network is unreachable')) {
      return 'Unable to connect right now. Check your internet connection and try again.';
    }
    if (message.contains('JWT') || message.contains('not authenticated')) {
      return 'Your session expired. Please sign in again.';
    }
    return 'Unable to load $area. Pull to refresh or try again.';
  }
}
