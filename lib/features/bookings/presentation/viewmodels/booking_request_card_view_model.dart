part of fixmate_app;

class BookingRequestCardViewModel {
  BookingRequestCardViewModel({
    required this.repo,
    required this.booking,
  });

  final ServiceRepository repo;
  final Map<String, dynamic> booking;

  Future<void> accept() => repo.updateBookingStatus(booking['id'], 'accepted');

  Future<void> reject() => repo.updateBookingStatus(booking['id'], 'rejected');

  Future<void> start() =>
      repo.updateBookingStatus(booking['id'], 'in_progress');

  Future<void> complete() =>
      repo.updateBookingStatus(booking['id'], 'completed');

  Future<String?> ensureChat() => repo.ensureChat(booking);
}

