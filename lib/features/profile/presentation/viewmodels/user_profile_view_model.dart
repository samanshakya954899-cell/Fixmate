part of fixmate_app;

class UserProfileViewModel extends ChangeNotifier {
  UserProfileViewModel(this._repo);

  final ServiceRepository _repo;

  final fullName = TextEditingController();
  final phone = TextEditingController();
  final city = TextEditingController();
  final address = TextEditingController();
  final business = TextEditingController();
  final bio = TextEditingController();
  final area = TextEditingController();
  final experience = TextEditingController(text: '1');

  bool available = true;

  String get currentEmail => _repo.currentEmail;

  void setAvailable(bool value) {
    available = value;
    notifyListeners();
  }

  Future<void> saveCustomerProfile() {
    return _repo.saveProfile(
      fullName: fullName.text.trim(),
      phone: phone.text.trim(),
      city: city.text.trim(),
      address: address.text.trim(),
    );
  }

  Future<void> saveProviderProfile() {
    return _repo.saveProviderProfile(
      businessName: business.text.trim(),
      bio: bio.text.trim(),
      serviceArea: area.text.trim(),
      experienceYears: int.tryParse(experience.text) ?? 0,
      available: available,
    );
  }

  Future<void> signOut() => _repo.signOut();

  @override
  void dispose() {
    fullName.dispose();
    phone.dispose();
    city.dispose();
    address.dispose();
    business.dispose();
    bio.dispose();
    area.dispose();
    experience.dispose();
    super.dispose();
  }
}

