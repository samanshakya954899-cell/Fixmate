part of fixmate_app;

class BookingRequestFormViewModel {
  BookingRequestFormViewModel({
    required this.repo,
    required this.categoryId,
    required this.type,
    this.service,
  });

  final ServiceRepository repo;
  final String categoryId;
  final String type;
  final Map<String, dynamic>? service;

  final issue = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final preferred = TextEditingController();

  Future<String?> submit() async {
    if (issue.text.trim().isEmpty || address.text.trim().isEmpty) {
      return 'Problem description and address are required.';
    }
    await repo.createBooking(
      categoryId: categoryId,
      issue: issue.text.trim(),
      address: address.text.trim(),
      city: city.text.trim(),
      preferredAt:
          preferred.text.isEmpty ? null : DateTime.tryParse(preferred.text),
      type: type,
      providerId: service?['provider_id'] as String?,
      serviceId: service?['id'] as String?,
      quotedCharge: _asDouble(service?['base_charge']),
    );
    return null;
  }

  void dispose() {
    issue.dispose();
    address.dispose();
    city.dispose();
    preferred.dispose();
  }
}

