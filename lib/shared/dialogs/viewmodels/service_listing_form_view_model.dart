part of fixmate_app;

class ServiceListingFormViewModel extends ChangeNotifier {
  ServiceListingFormViewModel(this._repo);

  final ServiceRepository _repo;

  final description = TextEditingController();
  final charge = TextEditingController();
  final city = TextEditingController();
  final area = TextEditingController();

  List<Map<String, dynamic>> categories = [];
  String? categoryId;
  bool loading = true;
  bool saving = false;
  String? errorMessage;
  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    _notify();
    try {
      categories = await _repo.categories();
      categoryId = categories.isEmpty ? null : categories.first['id'] as String;
      if (categories.isEmpty) {
        errorMessage = 'No service categories are available yet.';
      }
    } catch (e) {
      categories = [];
      categoryId = null;
      errorMessage = _friendlyFormError(e);
    } finally {
      loading = false;
      _notify();
    }
  }

  void selectCategory(String? value) {
    categoryId = value ?? categoryId;
    errorMessage = null;
    _notify();
  }

  Future<bool> save() async {
    if (saving) return false;
    final selectedCategoryId = categoryId;
    final parsedCharge = double.tryParse(charge.text.trim());
    if (selectedCategoryId == null) {
      errorMessage = 'Choose a service category.';
      _notify();
      return false;
    }
    if (description.text.trim().isEmpty) {
      errorMessage = 'Enter a short service description.';
      _notify();
      return false;
    }
    if (parsedCharge == null || parsedCharge <= 0) {
      errorMessage = 'Enter a valid base charge.';
      _notify();
      return false;
    }
    if (city.text.trim().isEmpty) {
      errorMessage = 'Enter the city you serve.';
      _notify();
      return false;
    }
    if (area.text.trim().isEmpty) {
      errorMessage = 'Enter your service area.';
      _notify();
      return false;
    }

    saving = true;
    errorMessage = null;
    _notify();
    try {
      final selectedCategory = categories.firstWhere(
        (category) => category['id'] == selectedCategoryId,
      );
      await _repo.addProviderService(
        categoryId: selectedCategoryId,
        title: selectedCategory['name']?.toString() ?? 'Service',
        description: description.text.trim(),
        charge: parsedCharge,
        city: city.text.trim(),
        serviceArea: area.text.trim(),
      );
      return true;
    } catch (e) {
      errorMessage = _friendlyFormError(e);
      return false;
    } finally {
      saving = false;
      _notify();
    }
  }

  String _friendlyFormError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('Backend tables are missing') ||
        message.contains('PGRST205') ||
        message.contains('schema cache') ||
        message.contains('Could not find the table')) {
      return 'Backend tables are missing. Run supabase/fixmate_setup.sql in Supabase, then add the service again.';
    }
    if (message.contains('SocketException') ||
        message.contains('Failed host lookup') ||
        message.contains('TimeoutException') ||
        message.contains('Network is unreachable')) {
      return 'Unable to connect right now. Check your internet connection and try again.';
    }
    if (message.contains('row-level security') ||
        message.contains('violates row-level security')) {
      return 'Supabase blocked this save. Please sign in as a provider and try again.';
    }
    if (message.contains('foreign key') ||
        message.contains('provider_services_provider_id_fkey')) {
      return 'Create or save your provider profile first, then add a service.';
    }
    if (message.contains('Please sign in again')) {
      return 'Please sign in again before adding a service.';
    }
    return message.isEmpty ? 'Unable to save service. Try again.' : message;
  }

  @override
  void dispose() {
    _disposed = true;
    description.dispose();
    charge.dispose();
    city.dispose();
    area.dispose();
    super.dispose();
  }
}
