part of fixmate_app;

class ServiceBookingRepository implements ServiceRepository {
  ServiceBookingRepository(this.configured);

  final bool configured;
  final _uuid = const Uuid();

  SupabaseClient get _client => Supabase.instance.client;

  String get currentUserId =>
      configured ? _client.auth.currentUser!.id : 'demo-user';

  String get currentEmail =>
      configured ? (_client.auth.currentUser?.email ?? '') : 'demo@fixseva.app';

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
      'description': 'Split and window AC servicing, cooling issues, and gas refills.',
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

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(
    String name,
    String email,
    String password,
    String accountType,
  ) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'account_type': accountType},
    );
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    if (configured) await _client.auth.signOut();
  }

  Future<List<Map<String, dynamic>>> categories() async {
    if (!configured) return List.of(_demoCategories);
    final data = await _client
        .from('service_categories')
        .select()
        .eq('is_active', true)
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> providerServices(
      {String? categoryId}) async {
    if (!configured) {
      return _demoServices
          .where((service) =>
              categoryId == null || service['category_id'] == categoryId)
          .toList();
    }
    var query = _client.from('provider_services').select(
          '*, service_categories(name), provider_profiles(business_name, experience_years, is_available)',
        );
    if (categoryId != null) query = query.eq('category_id', categoryId);
    final data = await query.eq('is_available', true).order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> saveProfile({
    required String fullName,
    required String phone,
    required String city,
    required String address,
  }) async {
    if (!configured) return;
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
    if (!configured) return;
    await _client.from('provider_profiles').upsert({
      'id': currentUserId,
      'business_name': businessName,
      'bio': bio,
      'service_area': serviceArea,
      'experience_years': experienceYears,
      'is_available': available,
    });
    await _client.from('profiles').upsert({
      'id': currentUserId,
      'roles': ['customer', 'provider'],
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
    if (!configured) {
      _demoServices.add({
        'id': _uuid.v4(),
        'provider_id': currentUserId,
        'category_id': categoryId,
        'title': title,
        'description': description,
        'base_charge': charge,
        'city': city,
        'service_area': serviceArea,
        'is_available': true,
        'service_categories': {
          'name':
              _demoCategories.firstWhere((c) => c['id'] == categoryId)['name'],
        },
        'provider_profiles': {
          'business_name': 'My Service',
          'experience_years': 1,
          'is_available': true,
        },
      });
      return;
    }
    await _client.from('provider_services').insert({
      'provider_id': currentUserId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'base_charge': charge,
      'city': city,
      'service_area': serviceArea,
    });
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
    if (!configured) {
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
    if (!configured) return List.of(_demoBookings);
    final data = await _client
        .from('booking_requests')
        .select('*, service_categories(name)')
        .or('customer_id.eq.$currentUserId,provider_id.eq.$currentUserId')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> providerIncomingBookings() async {
    if (!configured) return List.of(_demoBookings);
    final data = await _client
        .from('booking_requests')
        .select('*, service_categories(name)')
        .or('provider_id.eq.$currentUserId,booking_type.eq.open')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (!configured) {
      final booking = _demoBookings.firstWhere((b) => b['id'] == bookingId);
      booking['status'] = status;
      if (status == 'accepted') booking['provider_id'] ??= currentUserId;
      return;
    }
    final patch = <String, dynamic>{'status': status};
    if (status == 'accepted') patch['provider_id'] = currentUserId;
    await _client.from('booking_requests').update(patch).eq('id', bookingId);
  }

  Future<String?> ensureChat(Map<String, dynamic> booking) async {
    final providerId = booking['provider_id'] as String?;
    if (providerId == null || providerId.isEmpty) return null;
    if (!configured) return booking['id'] as String;
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
    if (!configured) {
      return _demoMessages.where((m) => m['chat_id'] == chatId).toList();
    }
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> sendMessage(String chatId, String body) async {
    if (!configured) {
      _demoMessages.add({
        'id': _uuid.v4(),
        'chat_id': chatId,
        'sender_id': currentUserId,
        'body': body,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }
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
    if (!configured) return;
    await _client.from('ratings').insert({
      'booking_id': booking['id'],
      'customer_id': currentUserId,
      'provider_id': providerId,
      'stars': stars,
      'review': review,
    });
  }

  Future<List<Map<String, dynamic>>> notifications() async {
    if (!configured) return List.of(_demoNotifications);
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', currentUserId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}

