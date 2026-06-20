part of fixmate_app;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.repo,
    required this.demoMode,
    required this.mode,
    required this.onSignOut,
  });

  final ServiceRepository repo;
  final bool demoMode;
  final String mode;
  final VoidCallback onSignOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserProfileViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = UserProfileViewModel(widget.repo);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppHero(
          icon: Icons.account_circle_outlined,
          title: widget.mode == 'provider'
              ? 'Provider profile'
              : 'Customer profile',
          subtitle: viewModel.currentEmail,
        ),
        if (widget.demoMode) ...[
          const SizedBox(height: 12),
          const InfoBanner(
            icon: Icons.info_outline,
            text:
                'Demo mode: add Supabase keys to enable real authentication and backend data.',
          ),
        ],
        const SizedBox(height: 16),
        if (widget.mode == 'customer')
          FormPanel(
            icon: Icons.person_outline,
            title: 'Customer profile',
            children: [
              TextField(
                controller: viewModel.fullName,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: viewModel.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: viewModel.city,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: viewModel.address,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () async {
                  await viewModel.saveCustomerProfile();
                  if (context.mounted) _snack(context, 'Profile saved');
                },
                icon: const Icon(Icons.save),
                label: const Text('Save customer profile'),
              ),
            ],
          ),
        if (widget.mode == 'provider')
          FormPanel(
            icon: Icons.engineering_outlined,
            title: 'Provider profile',
            children: [
              TextField(
                controller: viewModel.business,
                decoration: const InputDecoration(
                  labelText: 'Business name',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: viewModel.bio,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: viewModel.area,
                decoration: const InputDecoration(
                  labelText: 'Service area',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: viewModel.experience,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Experience years',
                  prefixIcon: Icon(Icons.workspace_premium_outlined),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: viewModel.available,
                onChanged: viewModel.setAvailable,
                title: const Text(
                  'Available for work',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () async {
                  await viewModel.saveProviderProfile();
                  if (context.mounted) {
                    _snack(context, 'Provider profile saved');
                  }
                },
                icon: const Icon(Icons.engineering),
                label: const Text('Save provider profile'),
              ),
            ],
          ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () async {
            await viewModel.signOut();
            widget.onSignOut();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
      ),
    );
  }
}


