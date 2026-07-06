part of fixmate_app;

class BackendServiceBookingRepository implements ServiceRepository {
  BackendServiceBookingRepository(String baseUrl)
      : _baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');

  final Uri _baseUri;
  final http.Client _http = http.Client();
  String? _cookie;
  Map<String, dynamic>? _user;
  String _preferredRole = 'customer';

  static const _requestTimeout = Duration(seconds: 15);

  @override
  bool get configured => true;

  @override
  String get currentUserId => (_user?['id'] as String?) ?? '';

  @override
  String get currentEmail => (_user?['email'] as String?) ?? '';

  @override
  String get preferredRole => _preferredRole;

  @override
  Future<void> signIn(String email, String password) async {
    final response = await _request(
      'api/auth/signin/',
      method: 'POST',
      body: {'email': email, 'password': password},
    );
    _user = Map<String, dynamic>.from(response['user'] as Map);
  }

  @override
  Future<bool> signUp(
    String name,
    String email,
    String password,
    String accountType,
  ) async {
    final response = await _request(
      'api/auth/signup/',
      method: 'POST',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'account_type': _normalizedRole(accountType),
      },
    );
    _user = Map<String, dynamic>.from(response['user'] as Map);
    _preferredRole = _normalizedRole(accountType);
    return true;
  }

  @override
  Future<void> rememberPreferredRole(String role) async {
    _preferredRole = _normalizedRole(role);
  }

  @override
  Future<void> resetPassword(String email) async {
    throw Exception('Password reset is not available on the Django backend yet.');
  }

  @override
  Future<void> signOut() async {
    await _request('api/auth/signout/', method: 'POST');
    _cookie = null;
    _user = null;
    _preferredRole = 'customer';
  }

  @override
  Future<List<Map<String, dynamic>>> categories() async {
    return _dataList(await _request('api/categories/'));
  }

  @override
  Future<List<Map<String, dynamic>>> providerServices({
    String? categoryId,
  }) async {
    return _dataList(
      await _request(
        'api/provider-services/',
        query: categoryId == null ? null : {'category_id': categoryId},
      ),
    );
  }

  @override
  Future<void> saveProfile({
    required String fullName,
    required String phone,
    required String city,
    required String address,
  }) async {
    final response = await _request(
      'api/profile/',
      method: 'POST',
      body: {
        'full_name': fullName,
        'phone': phone,
        'city': city,
        'address': address,
        'roles': ['customer', 'provider'],
      },
    );
    _user = Map<String, dynamic>.from(response['data'] as Map);
  }

  @override
  Future<void> saveProviderProfile({
    required String businessName,
    required String bio,
    required String serviceArea,
    required int experienceYears,
    required bool available,
  }) async {
    await _request(
      'api/provider-profile/',
      method: 'POST',
      body: {
        'business_name': businessName,
        'bio': bio,
        'service_area': serviceArea,
        'experience_years': experienceYears,
        'available': available,
      },
    );
  }

  @override
  Future<void> addProviderService({
    required String categoryId,
    required String title,
    required String description,
    required double charge,
    required String city,
    required String serviceArea,
  }) async {
    await _request(
      'api/provider-services/',
      method: 'POST',
      body: {
        'category_id': categoryId,
        'title': title,
        'description': description,
        'charge': charge,
        'city': city,
        'service_area': serviceArea,
      },
    );
  }

  @override
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
  }) async {
    await _request(
      'api/bookings/',
      method: 'POST',
      body: {
        'category_id': categoryId,
        'issue': issue,
        'address': address,
        'city': city,
        'preferred_at': preferredAt?.toIso8601String(),
        'type': type,
        'provider_id': providerId,
        'service_id': serviceId,
        'quoted_charge': quotedCharge,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> bookings() async {
    return _dataList(await _request('api/bookings/'));
  }

  @override
  Future<List<Map<String, dynamic>>> providerIncomingBookings() async {
    return _dataList(await _request('api/provider-bookings/'));
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _request(
      'api/bookings/$bookingId/status/',
      method: 'POST',
      body: {'status': status},
    );
  }

  @override
  Future<String?> ensureChat(Map<String, dynamic> booking) async {
    final providerId = booking['provider_id'] as String?;
    if (providerId == null || providerId.isEmpty) return null;
    final response = await _request(
      'api/chats/ensure/',
      method: 'POST',
      body: {'booking_id': booking['id']},
    );
    final data = Map<String, dynamic>.from(response['data'] as Map);
    return data['id'] as String?;
  }

  @override
  Future<List<Map<String, dynamic>>> messages(String chatId) async {
    return _dataList(await _request('api/chats/$chatId/messages/'));
  }

  @override
  Future<void> sendMessage(String chatId, String body) async {
    await _request(
      'api/chats/$chatId/messages/',
      method: 'POST',
      body: {'body': body},
    );
  }

  @override
  Future<void> rateBooking(
    Map<String, dynamic> booking,
    int stars,
    String review,
  ) async {
    await _request(
      'api/bookings/${booking['id']}/rating/',
      method: 'POST',
      body: {'stars': stars, 'review': review},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> notifications() async {
    return _dataList(await _request('api/notifications/'));
  }

  Future<Map<String, dynamic>> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = _uri(path, query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (_cookie != null) 'Cookie': _cookie!,
    };
    final encodedBody = body == null ? null : jsonEncode(body);
    late final http.Response response;
    if (method == 'POST') {
      response = await _http
          .post(uri, headers: headers, body: encodedBody)
          .timeout(_requestTimeout);
    } else if (method == 'PUT') {
      response = await _http
          .put(uri, headers: headers, body: encodedBody)
          .timeout(_requestTimeout);
    } else if (method == 'PATCH') {
      response = await _http
          .patch(uri, headers: headers, body: encodedBody)
          .timeout(_requestTimeout);
    } else {
      response = await _http.get(uri, headers: headers).timeout(_requestTimeout);
    }
    _storeCookie(response);
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(decoded['error'] ?? 'Backend request failed.');
    }
    return decoded;
  }

  Uri _uri(String path, Map<String, String>? query) {
    final uri = _baseUri.resolve(path);
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }

  void _storeCookie(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie == null || setCookie.isEmpty) return;
    final cookies = <String>[];
    for (final part in setCookie.split(',')) {
      final cookie = part.split(';').first.trim();
      if (cookie.contains('=')) cookies.add(cookie);
    }
    if (cookies.isNotEmpty) _cookie = cookies.join('; ');
  }

  List<Map<String, dynamic>> _dataList(Map<String, dynamic> response) {
    final data = response['data'] as List? ?? const [];
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  String _normalizedRole(dynamic value) {
    return value == 'provider' ? 'provider' : 'customer';
  }
}
