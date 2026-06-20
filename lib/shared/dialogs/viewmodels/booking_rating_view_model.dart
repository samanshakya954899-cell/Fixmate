part of fixmate_app;

class BookingRatingViewModel extends ChangeNotifier {
  BookingRatingViewModel({
    required this.repo,
    required this.booking,
  });

  final ServiceRepository repo;
  final Map<String, dynamic> booking;
  final review = TextEditingController();

  int stars = 5;

  void setStars(int value) {
    stars = value;
    notifyListeners();
  }

  Future<void> submit() => repo.rateBooking(booking, stars, review.text.trim());

  @override
  void dispose() {
    review.dispose();
    super.dispose();
  }
}

