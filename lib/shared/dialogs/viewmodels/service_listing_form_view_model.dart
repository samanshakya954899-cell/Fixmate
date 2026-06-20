part of fixmate_app;

class ServiceListingFormViewModel extends ChangeNotifier {
  ServiceListingFormViewModel(this._repo);

  final ServiceRepository _repo;

  final title = TextEditingController();
  final description = TextEditingController();
  final charge = TextEditingController();
  final city = TextEditingController();
  final area = TextEditingController();

  List<Map<String, dynamic>> categories = [];
  String? categoryId;
  bool loading = true;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    categories = await _repo.categories();
    categoryId = categories.isEmpty ? null : categories.first['id'] as String;
    loading = false;
    notifyListeners();
  }

  void selectCategory(String? value) {
    categoryId = value ?? categoryId;
    notifyListeners();
  }

  Future<void> save() async {
    final selectedCategoryId = categoryId;
    if (selectedCategoryId == null) return;
    await _repo.addProviderService(
      categoryId: selectedCategoryId,
      title: title.text.trim(),
      description: description.text.trim(),
      charge: double.tryParse(charge.text) ?? 0,
      city: city.text.trim(),
      serviceArea: area.text.trim(),
    );
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    charge.dispose();
    city.dispose();
    area.dispose();
    super.dispose();
  }
}

