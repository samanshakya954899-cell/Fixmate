part of fixmate_app;

class CustomerServicesViewModel extends ChangeNotifier {
  CustomerServicesViewModel(this._repo);

  final ServiceRepository _repo;

  String? categoryId;
  bool loading = true;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> services = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();
    categories = await _repo.categories();
    services = await _repo.providerServices(categoryId: categoryId);
    loading = false;
    notifyListeners();
  }

  Future<void> selectCategory(String value) async {
    categoryId = value;
    await load();
  }

  Future<void> refresh() => load();
}

