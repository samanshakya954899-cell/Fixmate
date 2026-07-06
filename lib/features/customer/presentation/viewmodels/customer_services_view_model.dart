part of fixmate_app;

class CustomerServicesViewModel extends ChangeNotifier {
  CustomerServicesViewModel(this._repo);

  final ServiceRepository _repo;

  String? categoryId;
  bool loading = true;
  String? errorMessage;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> services = [];

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      categories = await _repo.categories();
      services = await _repo.providerServices(categoryId: categoryId);
    } catch (e) {
      services = [];
      errorMessage = _friendlyServicesError(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String value) async {
    categoryId = value;
    await load();
  }

  Future<void> refresh() => load();

  String _friendlyServicesError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('Backend tables are missing') ||
        message.contains('PGRST205') ||
        message.contains('schema cache') ||
        message.contains('Could not find the table')) {
      return 'Backend tables are missing. Run supabase/fixmate_setup.sql in Supabase, then refresh services.';
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
    return 'Unable to load services. Pull to refresh or try again.';
  }
}
