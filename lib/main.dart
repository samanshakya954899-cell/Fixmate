import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configured = _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;
  if (configured) {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );
  }
  runApp(ServiceBookingApp(configured: configured));
}

class ServiceBookingApp extends StatelessWidget {
  const ServiceBookingApp({super.key, required this.configured});

  final bool configured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FixSeva',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7C7B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        useMaterial3: true,
      ),
      home: AuthGate(configured: configured),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.configured});

  final bool configured;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AppRepository repo;
  Session? session;

  @override
  void initState() {
    super.initState();
    repo = AppRepository(widget.configured);
    if (widget.configured) {
      session = Supabase.instance.client.auth.currentSession;
      Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        if (mounted) setState(() => session = event.session);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.configured) {
      return HomeShell(repo: repo, demoMode: true);
    }
    if (session == null) {
      return AuthScreen(repo: repo);
    }
    return HomeShell(repo: repo);
  }
}

class AppRepository {
  AppRepository(this.configured);

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
      'title': 'AC service aur gas refill',
      'description': 'Split/window AC servicing, cooling issue, gas refill.',
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
      'description': 'Display, sound, power board aur installation work.',
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

  Future<void> signUp(String name, String email, String password) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
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
          'business_name': 'Meri Service',
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
        'body': 'Aapki service request submit ho gayi hai.',
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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.repo});

  final AppRepository repo;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool signup = false;
  bool busy = false;

  Future<void> submit() async {
    setState(() => busy = true);
    try {
      if (signup) {
        await widget.repo
            .signUp(name.text.trim(), email.text.trim(), password.text);
        if (mounted) {
          _snack(context, 'Signup ho gaya. Email confirm karke login karein.');
        }
      } else {
        await widget.repo.signIn(email.text.trim(), password.text);
      }
    } catch (e) {
      if (mounted) _snack(context, e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.home_repair_service,
                      size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    signup ? 'Naya account banayein' : 'FixSeva login',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customer aur provider dono mode ek hi app me.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (signup) ...[
                    TextField(
                        controller: name,
                        decoration:
                            const InputDecoration(labelText: 'Full name')),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                      controller: email,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: busy ? null : submit,
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.login),
                    label: Text(signup ? 'Signup' : 'Login'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => signup = !signup),
                    child: Text(signup
                        ? 'Already account hai? Login'
                        : 'Naya account banayein'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (email.text.trim().isEmpty) {
                        _snack(
                            context, 'Password reset ke liye email daalein.');
                        return;
                      }
                      await widget.repo.resetPassword(email.text.trim());
                      if (!context.mounted) return;
                      _snack(context, 'Reset email bhej diya gaya.');
                    },
                    child: const Text('Forgot password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repo, this.demoMode = false});

  final AppRepository repo;
  final bool demoMode;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      CustomerHome(repo: widget.repo),
      ProviderHome(repo: widget.repo),
      BookingsScreen(repo: widget.repo),
      ProfileScreen(repo: widget.repo, demoMode: widget.demoMode),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('FixSeva'),
        actions: [
          if (widget.demoMode)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Chip(label: Text('Demo')),
            ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => NotificationsScreen(repo: widget.repo)),
            ),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Customer'),
          NavigationDestination(
              icon: Icon(Icons.engineering), label: 'Provider'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key, required this.repo});

  final AppRepository repo;

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  String? categoryId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Service choose karein',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: widget.repo.categories(),
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) return const LinearProgressIndicator();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in categories)
                    ChoiceChip(
                      avatar: Icon(_iconFor(category['icon_name']), size: 18),
                      label: Text(category['name']),
                      selected: categoryId == category['id'],
                      onSelected: (_) =>
                          setState(() => categoryId = category['id'] as String),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: categoryId == null
                ? null
                : () => _openBookingForm(context, widget.repo, categoryId!,
                    type: 'open'),
            icon: const Icon(Icons.campaign),
            label: const Text('Open request bhejein'),
          ),
          const SizedBox(height: 18),
          Text('Available providers',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: widget.repo.providerServices(categoryId: categoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final services = snapshot.data!;
              if (services.isEmpty) {
                return const EmptyState(
                    text: 'Is category me provider abhi nahi mila.');
              }
              return Column(
                children: [
                  for (final service in services)
                    ServiceCard(
                      service: service,
                      onBook: () => _openBookingForm(
                        context,
                        widget.repo,
                        service['category_id'] as String,
                        type: 'direct',
                        service: service,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onBook});

  final Map<String, dynamic> service;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final provider =
        service['provider_profiles'] as Map<String, dynamic>? ?? {};
    final category =
        service['service_categories'] as Map<String, dynamic>? ?? {};
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(service['title'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text('Rs ${service['base_charge'] ?? 0}'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
                '${category['name'] ?? ''} • ${provider['business_name'] ?? 'Provider'}'),
            const SizedBox(height: 6),
            Text(service['description'] ?? ''),
            const SizedBox(height: 6),
            Text('Area: ${service['service_area'] ?? service['city'] ?? ''}'),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onBook,
                icon: const Icon(Icons.calendar_month),
                label: const Text('Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderHome extends StatefulWidget {
  const ProviderHome({super.key, required this.repo});

  final AppRepository repo;

  @override
  State<ProviderHome> createState() => _ProviderHomeState();
}

class _ProviderHomeState extends State<ProviderHome> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: () => _openProviderServiceForm(context, widget.repo)
                .then((_) => setState(() {})),
            icon: const Icon(Icons.add_business),
            label: const Text('Apni service add karein'),
          ),
          const SizedBox(height: 16),
          Text('Incoming requests',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: widget.repo.providerIncomingBookings(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final bookings = snapshot.data!;
              if (bookings.isEmpty) {
                return const EmptyState(text: 'Abhi koi request nahi hai.');
              }
              return Column(
                children: [
                  for (final booking in bookings)
                    BookingCard(
                      booking: booking,
                      repo: widget.repo,
                      showProviderActions: true,
                      onChanged: () => setState(() {}),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Meri services', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: widget.repo.providerServices(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              final services = snapshot.data!
                  .where((service) =>
                      !widget.repo.configured ||
                      service['provider_id'] == widget.repo.currentUserId)
                  .toList();
              if (services.isEmpty) {
                return const EmptyState(
                    text: 'Service add karne ke baad yahan dikhegi.');
              }
              return Column(
                children: [
                  for (final service in services)
                    ServiceCard(service: service, onBook: () {}),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key, required this.repo});

  final AppRepository repo;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.repo.bookings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data!;
          if (bookings.isEmpty) {
            return const EmptyState(text: 'Aapki bookings yahan dikhegi.');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final booking in bookings)
                BookingCard(
                  booking: booking,
                  repo: widget.repo,
                  showProviderActions: false,
                  onChanged: () => setState(() {}),
                ),
            ],
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.repo,
    required this.showProviderActions,
    required this.onChanged,
  });

  final Map<String, dynamic> booking;
  final AppRepository repo;
  final bool showProviderActions;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final category =
        booking['service_categories'] as Map<String, dynamic>? ?? {};
    final status = booking['status'] as String? ?? 'pending';
    final canChat = booking['provider_id'] != null &&
        status != 'pending' &&
        status != 'rejected';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(category['name'] ?? 'Service',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Chip(label: Text(status)),
              ],
            ),
            Text(booking['issue_description'] ?? ''),
            const SizedBox(height: 6),
            Text('Address: ${booking['address'] ?? ''}'),
            if (booking['preferred_at'] != null)
              Text('Time: ${_formatDate(booking['preferred_at'])}'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                if (showProviderActions && status == 'pending') ...[
                  FilledButton.icon(
                    onPressed: () async {
                      await repo.updateBookingStatus(booking['id'], 'accepted');
                      onChanged();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await repo.updateBookingStatus(booking['id'], 'rejected');
                      onChanged();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ],
                if (showProviderActions && status == 'accepted')
                  OutlinedButton.icon(
                    onPressed: () async {
                      await repo.updateBookingStatus(
                          booking['id'], 'in_progress');
                      onChanged();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                if (status == 'in_progress')
                  OutlinedButton.icon(
                    onPressed: () async {
                      await repo.updateBookingStatus(
                          booking['id'], 'completed');
                      onChanged();
                    },
                    icon: const Icon(Icons.done_all),
                    label: const Text('Complete'),
                  ),
                if (canChat)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final chatId = await repo.ensureChat(booking);
                      if (chatId != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatScreen(repo: repo, chatId: chatId),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat'),
                  ),
                if (status == 'completed')
                  OutlinedButton.icon(
                    onPressed: () => _openRatingSheet(context, repo, booking),
                    icon: const Icon(Icons.star_border),
                    label: const Text('Rate'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.repo, required this.chatId});

  final AppRepository repo;
  final String chatId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking chat')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: widget.repo.messages(widget.chatId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (messages.isEmpty) {
                  return const EmptyState(text: 'Pehla message bhejein.');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final item = messages[index];
                    final mine = item['sender_id'] == widget.repo.currentUserId;
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: mine
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item['body'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: message,
                      decoration: const InputDecoration(labelText: 'Message'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () async {
                      if (message.text.trim().isEmpty) return;
                      await widget.repo
                          .sendMessage(widget.chatId, message.text.trim());
                      message.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.repo, required this.demoMode});

  final AppRepository repo;
  final bool demoMode;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final fullName = TextEditingController();
  final phone = TextEditingController();
  final city = TextEditingController();
  final address = TextEditingController();
  final business = TextEditingController();
  final bio = TextEditingController();
  final area = TextEditingController();
  final experience = TextEditingController(text: '1');
  bool available = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Account', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(widget.repo.currentEmail),
        if (widget.demoMode)
          const Text(
              'Demo mode: Supabase keys add karne par real login/backend chalega.'),
        const SizedBox(height: 18),
        Text('Customer profile',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
            controller: fullName,
            decoration: const InputDecoration(labelText: 'Full name')),
        const SizedBox(height: 8),
        TextField(
            controller: phone,
            decoration: const InputDecoration(labelText: 'Phone')),
        const SizedBox(height: 8),
        TextField(
            controller: city,
            decoration: const InputDecoration(labelText: 'City')),
        const SizedBox(height: 8),
        TextField(
            controller: address,
            decoration: const InputDecoration(labelText: 'Address')),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () async {
            await widget.repo.saveProfile(
              fullName: fullName.text.trim(),
              phone: phone.text.trim(),
              city: city.text.trim(),
              address: address.text.trim(),
            );
            if (context.mounted) _snack(context, 'Profile saved');
          },
          icon: const Icon(Icons.save),
          label: const Text('Save customer profile'),
        ),
        const SizedBox(height: 24),
        Text('Provider profile',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
            controller: business,
            decoration: const InputDecoration(labelText: 'Business name')),
        const SizedBox(height: 8),
        TextField(
            controller: bio,
            decoration: const InputDecoration(labelText: 'Bio')),
        const SizedBox(height: 8),
        TextField(
            controller: area,
            decoration: const InputDecoration(labelText: 'Service area')),
        const SizedBox(height: 8),
        TextField(
          controller: experience,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Experience years'),
        ),
        SwitchListTile(
          value: available,
          onChanged: (value) => setState(() => available = value),
          title: const Text('Available for work'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await widget.repo.saveProviderProfile(
              businessName: business.text.trim(),
              bio: bio.text.trim(),
              serviceArea: area.text.trim(),
              experienceYears: int.tryParse(experience.text) ?? 0,
              available: available,
            );
            if (context.mounted) _snack(context, 'Provider profile saved');
          },
          icon: const Icon(Icons.engineering),
          label: const Text('Save provider profile'),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => widget.repo.signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.repo});

  final AppRepository repo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: repo.notifications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const EmptyState(text: 'Notifications abhi nahi hain.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['body'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}

Future<void> _openBookingForm(
  BuildContext context,
  AppRepository repo,
  String categoryId, {
  required String type,
  Map<String, dynamic>? service,
}) {
  final issue = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final preferred = TextEditingController();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              type == 'direct' ? 'Direct booking' : 'Open request',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
                controller: issue,
                decoration: const InputDecoration(
                    labelText: 'Problem describe karein')),
            const SizedBox(height: 8),
            TextField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 8),
            TextField(
                controller: city,
                decoration: const InputDecoration(labelText: 'City')),
            const SizedBox(height: 8),
            TextField(
              controller: preferred,
              readOnly: true,
              decoration:
                  const InputDecoration(labelText: 'Preferred date/time'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 45)),
                  initialDate: DateTime.now(),
                );
                if (date == null || !context.mounted) return;
                final time = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                if (time == null) return;
                preferred.text = DateTime(
                        date.year, date.month, date.day, time.hour, time.minute)
                    .toIso8601String();
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                if (issue.text.trim().isEmpty || address.text.trim().isEmpty) {
                  _snack(context, 'Problem aur address required hai.');
                  return;
                }
                await repo.createBooking(
                  categoryId: categoryId,
                  issue: issue.text.trim(),
                  address: address.text.trim(),
                  city: city.text.trim(),
                  preferredAt: preferred.text.isEmpty
                      ? null
                      : DateTime.tryParse(preferred.text),
                  type: type,
                  providerId: service?['provider_id'] as String?,
                  serviceId: service?['id'] as String?,
                  quotedCharge: _asDouble(service?['base_charge']),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _snack(context, 'Booking request bhej di gayi.');
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit request'),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _openProviderServiceForm(
    BuildContext context, AppRepository repo) async {
  final categories = await repo.categories();
  if (!context.mounted) return;
  String categoryId = categories.first['id'] as String;
  final title = TextEditingController();
  final description = TextEditingController();
  final charge = TextEditingController();
  final city = TextEditingController();
  final area = TextEditingController();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocalState) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Service add karein',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final category in categories)
                    DropdownMenuItem(
                        value: category['id'] as String,
                        child: Text(category['name'])),
                ],
                onChanged: (value) =>
                    setLocalState(() => categoryId = value ?? categoryId),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: title,
                  decoration:
                      const InputDecoration(labelText: 'Service title')),
              const SizedBox(height: 8),
              TextField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              TextField(
                controller: charge,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Base charge'),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: city,
                  decoration: const InputDecoration(labelText: 'City')),
              const SizedBox(height: 8),
              TextField(
                  controller: area,
                  decoration: const InputDecoration(labelText: 'Service area')),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  await repo.addProviderService(
                    categoryId: categoryId,
                    title: title.text.trim(),
                    description: description.text.trim(),
                    charge: double.tryParse(charge.text) ?? 0,
                    city: city.text.trim(),
                    serviceArea: area.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    _snack(context, 'Service saved');
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save service'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _openRatingSheet(
  BuildContext context,
  AppRepository repo,
  Map<String, dynamic> booking,
) async {
  int stars = 5;
  final review = TextEditingController();
  await showModalBottomSheet(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocalState) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Rate provider',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 4, label: Text('4')),
                ButtonSegment(value: 5, label: Text('5')),
              ],
              selected: {stars},
              onSelectionChanged: (value) =>
                  setLocalState(() => stars = value.first),
            ),
            const SizedBox(height: 8),
            TextField(
                controller: review,
                decoration: const InputDecoration(labelText: 'Review')),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                await repo.rateBooking(booking, stars, review.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  _snack(context, 'Rating saved');
                }
              },
              icon: const Icon(Icons.star),
              label: const Text('Submit rating'),
            ),
          ],
        ),
      ),
    ),
  );
}

IconData _iconFor(dynamic iconName) {
  switch (iconName) {
    case 'tv':
      return Icons.tv;
    case 'kitchen':
      return Icons.kitchen;
    case 'air':
      return Icons.air;
    case 'ac_unit':
      return Icons.ac_unit;
    default:
      return Icons.build;
  }
}

String _formatDate(dynamic raw) {
  final parsed = raw is DateTime ? raw : DateTime.tryParse(raw.toString());
  if (parsed == null) return raw.toString();
  return DateFormat('dd MMM, h:mm a').format(parsed);
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
