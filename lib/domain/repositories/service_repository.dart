part of fixmate_app;

abstract class ServiceRepository {
  bool get configured;
  String get currentUserId;
  String get currentEmail;

  Future<void> signIn(String email, String password);
  Future<void> signUp(
    String name,
    String email,
    String password,
    String accountType,
  );
  Future<void> resetPassword(String email);
  Future<void> signOut();

  Future<List<Map<String, dynamic>>> categories();
  Future<List<Map<String, dynamic>>> providerServices({String? categoryId});
  Future<void> saveProfile({
    required String fullName,
    required String phone,
    required String city,
    required String address,
  });
  Future<void> saveProviderProfile({
    required String businessName,
    required String bio,
    required String serviceArea,
    required int experienceYears,
    required bool available,
  });
  Future<void> addProviderService({
    required String categoryId,
    required String title,
    required String description,
    required double charge,
    required String city,
    required String serviceArea,
  });
  Future<void> createBooking({
    required String categoryId,
    required String issue,
    required String address,
    required String city,
    required DateTime? preferredAt,
    required String type,
    String? providerId,
    String? serviceId,
    double? quotedCharge,
  });
  Future<List<Map<String, dynamic>>> bookings();
  Future<List<Map<String, dynamic>>> providerIncomingBookings();
  Future<void> updateBookingStatus(String bookingId, String status);
  Future<String?> ensureChat(Map<String, dynamic> booking);
  Future<List<Map<String, dynamic>>> messages(String chatId);
  Future<void> sendMessage(String chatId, String body);
  Future<void> rateBooking(
    Map<String, dynamic> booking,
    int stars,
    String review,
  );
  Future<List<Map<String, dynamic>>> notifications();
}

