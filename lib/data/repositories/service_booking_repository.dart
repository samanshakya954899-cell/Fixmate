part of fixmate_app;

class ServiceBookingRepository implements ServiceRepository {
  ServiceBookingRepository(this.configured);

  final bool configured;
  final _uuid = const Uuid();
  static const _requestTimeout = Duration(seconds: 15);

  SupabaseClient get _client => Supabase.instance.client;

  User? get _currentUser => configured
      ? _client.auth.currentUser ?? _client.auth.currentSession?.user
      : null;

  bool get _hasCurrentUser => !configured || _currentUser != null;

  String get currentUserId =>
      configured ? (_currentUser?.id ?? '') : 'demo-user';

  String get currentEmail =>
      configured ? (_client.auth.currentUser?.email ?? '') : '';

  bool get _localStoreActive => !configured;

  String get preferredRole {
    if (!configured) return 'customer';
    final metadata = _currentUser?.userMetadata ?? {};
    return _normalizedRole(
      metadata['last_role'] ?? metadata['account_type'],
    );
  }

  final List<Map<String, dynamic>> _demoCategories = [
    {'id': 'cat-tv', 'name': 'TV', 'icon_name': 'tv'},
    {'id': 'cat-freezer', 'name': 'Freezer', 'icon_name': 'kitchen'},
    {'id': 'cat-cooler', 'name': 'Cooler', 'icon_name': 'air'},
    {'id': 'cat-ac', 'name': 'AC', 'icon_name': 'ac_unit'},
    {'id': 'cat-other', 'name': 'Other', 'icon_name': 'build'},
  ];

  late final List<Map<String, dynamic>> _demoServices = [
    {
      'id': 'svc-1',
      'provider_id': 'provider-1',
      'category_id': 'cat-ac',
      'title': 'AC service and gas refill',
      'description':
          'Split and window AC servicing, cooling issues, and gas refills.',
      'base_charge': 499,
      'city': 'Delhi',
      'service_area': 'Rohini, Pitampura',
      'is_available': true,
      'service_categories': {'name': 'AC'},
      'provider_profiles': {
        'business_name': 'Kumar Cooling Care',
        'experience_years': 6,
        'is_available': true,
      },
    },
    {
      'id': 'svc-2',
      'provider_id': 'provider-2',
      'category_id': 'cat-tv',
      'title': 'LED TV repair',
      'description': 'Display, sound, power board, and installation work.',
      'base_charge': 350,
      'city': 'Delhi',
      'service_area': 'Dwarka, Janakpuri',
      'is_available': true,
      'service_categories': {'name': 'TV'},
      'provider_profiles': {
        'business_name': 'ScreenFix Expert',
        'experience_years': 4,
        'is_available': true,
      },
    },
  ];

  final List<Map<String, dynamic>> _demoBookings = [];
  final List<Map<String, dynamic>> _demoNotifications = [];
  final List<Map<String, dynamic>> _demoMessages = [];

  List<Map<String, dynamic>> _localProviderServices({String? categoryId}) {
    return _demoServices
        .where(
          (service) =>
              categoryId == null || service['category_id'] == categoryId,
        )
        .toList();
  }

  void _addLocalProviderService({
    required String categoryId,
    required String title,
    required String description,
    required double charge,
    required String city,
    required String serviceArea,
  }) {
    final category = _demoCategories.firstWhere(
      (item) => item['id'] == categoryId,
      orElse: () => _demoCategories.last,
    );
    _demoServices.insert(0, {
      'id': _uuid.v4(),
      'provider_id': currentUserId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'base_charge': charge,
      'city': city,
      'service_area': serviceArea,
      'is_available': true,
      'service_categories': {'name': category['name']},
      'provider_profiles': {
        'business_name': 'My Service',
        'experience_years': 1,
        'is_available': true,
      },
    });
  }

  bool _isMissingSchemaError(Object error) {
    final message = error.toString();
    return message.contains('PGRST205') ||
        message.contains('schema cache') ||
        message.contains('Could not find the table');
  }

  Exception _missingBackendSchemaException() {
    return Exception(
      'Backend tables are missing. Run supabase/fixmate_setup.sql in your Supabase SQL editor, then try again.',
    );
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<bool> signUp(
    String name,
    String email,
    String password,
    String accountType,
  ) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'account_type': _normalizedRole(accountType),
        'last_role': _normalizedRole(accountType),
      },
    );
    return response.session != null;
  }

  Future<bool> accountExists(String email) {
    throw Exception('Email OTP requires the FixMate Django backend.');
  }

  Future<void> requestSignupOtp({
    required String name,
    required String companyName,
    required String email,
    required String password,
    required String accountType,
  }) {
    throw Exception('Email OTP requires the FixMate Django backend.');
  }

  Future<void> verifySignupOtp(String email, String code) {
    throw Exception('Email OTP requires the FixMate Django backend.');
  }

  Future<void> requestSignInOtp(String email) {
    throw Exception('Email OTP requires the FixMate Django backend.');
  }

  Future<void> verifySignInOtp(String email, String code) {
    throw Exception('Email OTP requires the FixMate Django backend.');
  }

  Future<void> rememberPreferredRole(String role) async {
    if (!configured) return;
    final normalizedRole = _normalizedRole(role);
    final metadata =
        Map<String, dynamic>.from(_currentUser?.userMetadata ?? {});
    metadata['last_role'] = normalizedRole;
    metadata['account_type'] ??= normalizedRole;
    await _client.auth.updateUser(UserAttributes(data: metadata));
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    if (configured) await _client.auth.signOut();
  }

  Future<List<Map<String, dynamic>>> categories() async {
    if (_localStoreActive) return List.of(_demoCategories);
    if (!_hasCurrentUser) return [];
    try {
      final data = await _client
          .from('service_categories')
          .select()
          .eq('is_active', true)
          .order('name')
          .timeout(_requestTimeout);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (_isMissingSchemaError(e)) {
        throw _missingBackendSchemaException();
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> providerServices(
      {String? categoryId}) async {
    if (_localStoreActive)
      return _localProviderServices(categoryId: categoryId);
    if (!_hasCurrentUser) return [];
    try {
      var query = _client.from('provider_services').select(
            '*, service_categories(name), provider_profiles(business_name, experience_years, is_available)',
          );
      if (categoryId != null) query = query.eq('category_id', categoryId);
      final data = await query
          .eq('is_available', true)
          .order('created_at')
          .timeout(_requestTimeout);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (_isMissingSchemaError(e)) {
        throw _missingBackendSchemaException();
      }
      rethrow;
    }
  }

  Future<void> saveProfile({
    required String fullName,
    required String phone,
    required String city,
    required String address,
  }) async {
    if (_localStoreActive) return;
    if (!_hasCurrentUser) throw Exception('Please sign in again.');
    await _client.from('profiles').upsert({
      'id': currentUserId,
      'full_name': fullName,
      'phone': phone,
      'city': city,
      'address': address,
      'roles': ['customer', 'provider'],
    });
  }

  Future<void> saveProviderProfile({
    required String businessName,
    required String bio,
    required String serviceArea,
    required int experienceYears,
    required bool available,
  }) async {
    if (_localStoreActive) return;
    if (!_hasCurrentUser) throw Exception('Please sign in again.');
    await _client.from('profiles').upsert({
      'id': currentUserId,
      'full_name': _currentUser?.userMetadata?['full_name'] ?? '',
      'roles': ['customer', 'provider'],
    });
    await _client.from('provider_profiles').upsert({
      'id': currentUserId,
      'business_name': businessName,
      'bio': bio,
      'service_area': serviceArea,
      'experience_years': experienceYears,
      'is_available': available,
    });
  }

  Future<void> addProviderService({
    required String categoryId,
    required String title,
    required String description,
    required double charge,
    required String city,
    required String serviceArea,
  }) async {
    if (_localStoreActive) {
      _addLocalProviderService(
        categoryId: categoryId,
        title: title,
        description: description,
        charge: charge,
        city: city,
        serviceArea: serviceArea,
      );
      return;
    }
    if (!_hasCurrentUser) throw Exception('Please sign in again.');
    try {
      await _client.from('profiles').upsert({
        'id': currentUserId,
        'full_name': _currentUser?.userMetadata?['full_name'] ?? '',
        'roles': ['customer', 'provider'],
      }).timeout(_requestTimeout);
      await _client
          .from('provider_profiles')
          .upsert({'id': currentUserId}).timeout(_requestTimeout);
      await _client.from('provider_services').insert({
        'provider_id': currentUserId,
        'category_id': categoryId,
        'title': title,
        'description': description,
        'base_charge': charge,
        'city': city,
        'service_area': serviceArea,
      }).timeout(_requestTimeout);
    } catch (e) {
      if (_isMissingSchemaError(e)) {
        throw _missingBackendSchemaException();
      }
      rethrow;
    }
  }

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
    if (!_localStoreActive && !_hasCurrentUser) {
      throw Exception('Please sign in again.');
    }
    final booking = {
      'id': _uuid.v4(),
      'customer_id': currentUserId,
      'provider_id': providerId,
      'category_id': categoryId,
      'provider_service_id': serviceId,
      'booking_type': type,
      'status': 'pending',
      'issue_description': issue,
      'address': address,
      'city': city,
      'preferred_at': preferredAt?.toIso8601String(),
      'quoted_charge': quotedCharge,
      'created_at': DateTime.now().toIso8601String(),
    };
    if (_localStoreActive) {
      booking['service_categories'] =
          _demoCategories.firstWhere((c) => c['id'] == categoryId);
      _demoBookings.insert(0, booking);
      _demoNotifications.insert(0, {
        'id': _uuid.v4(),
        'title': 'Booking created',
        'body': 'Your service request has been submitted.',
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }
    await _client.from('booking_requests').insert({
      'customer_id': currentUserId,
      'provider_id': providerId,
      'category_id': categoryId,
      'provider_service_id': serviceId,
      'booking_type': type,
      'issue_description': issue,
      'address': address,
      'city': city,
      'preferred_at': preferredAt?.toIso8601String(),
      'quoted_charge': quotedCharge,
    });
  }

  Future<List<Map<String, dynamic>>> bookings() async {
    if (_localStoreActive) return List.of(_demoBookings);
    if (!_hasCurrentUser) return [];
    final data = await _client
        .from('booking_requests')
        .select('*, service_categories(name)')
        .or('customer_id.eq.$currentUserId,provider_id.eq.$currentUserId')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> providerIncomingBookings() async {
    if (_localStoreActive) return List.of(_demoBookings);
    if (!_hasCurrentUser) return [];
    try {
      final data = await _client
          .from('booking_requests')
          .select('*, service_categories(name)')
          .or('provider_id.eq.$currentUserId,booking_type.eq.open')
          .order('created_at', ascending: false)
          .timeout(_requestTimeout);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (_isMissingSchemaError(e)) {
        throw _missingBackendSchemaException();
      }
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (_localStoreActive) {
      final booking = _demoBookings.firstWhere((b) => b['id'] == bookingId);
      booking['status'] = status;
      if (status == 'accepted') booking['provider_id'] ??= currentUserId;
      return;
    }
    if (!_hasCurrentUser) throw Exception('Please sign in again.');
    final patch = <String, dynamic>{'status': status};
    if (status == 'accepted') patch['provider_id'] = currentUserId;
    await _client.from('booking_requests').update(patch).eq('id', bookingId);
  }

  Future<String?> ensureChat(Map<String, dynamic> booking) async {
    final providerId = booking['provider_id'] as String?;
    if (providerId == null || providerId.isEmpty) return null;
    if (_localStoreActive) return booking['id'] as String;
    if (!_hasCurrentUser) throw Exception('Please sign in again.');
    final existing = await _client
        .from('chats')
        .select('id')
        .eq('booking_id', booking['id'])
        .maybeSingle();
    if (existing != null) return existing['id'] as String;
    final created = await _client
        .from('chats')
        .insert({
          'booking_id': booking['id'],
          'customer_id': booking['customer_id'],
          'provider_id': providerId,
        })
        .select('id')
        .single();
    return created['id'] as String;
  }

  Future<List<Map<String, dynamic>>> messages(String chatId) async {
    if (_localStoreActive) {
      return _demoMessages.where((m) => m['chat_id'] == chatId).toList();
    }
    if (!_hasCurrentUser) return [];
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> sendMessage(String chatId, String body) async {
    if (_localStoreActive) {
      _demoMessages.add({
        'id': _uuid.v4(),
        'chat_id': chatId,
        'sender_id': currentUserId,
        'body': body,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }
    if (!_hasCurrentUser) throw Exception('Please sign in again.');
    await _client.from('chat_messages').insert({
      'chat_id': chatId,
      'sender_id': currentUserId,
      'body': body,
    });
  }

  Future<void> rateBooking(
    Map<String, dynamic> booking,
    int stars,
    String review,
  ) async {
    final providerId = booking['provider_id'] as String?;
    if (providerId == null) return;
    if (_localStoreActive) return;
    if (!_hasCurrentUser) throw Exception('Please sign in again.');
    await _client.from('ratings').insert({
      'booking_id': booking['id'],
      'customer_id': currentUserId,
      'provider_id': providerId,
      'stars': stars,
      'review': review,
    });
  }

  Future<List<Map<String, dynamic>>> notifications() async {
    if (_localStoreActive) return List.of(_demoNotifications);
    if (!_hasCurrentUser) return [];
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', currentUserId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  String _normalizedRole(dynamic value) {
    return value == 'provider' ? 'provider' : 'customer';
  }
}
