part of fixmate_app;

class ServiceListingCard extends StatelessWidget {
  const ServiceListingCard({super.key, required this.service, required this.onBook});

  final Map<String, dynamic> service;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final provider =
        service['provider_profiles'] as Map<String, dynamic>? ?? {};
    final category =
        service['service_categories'] as Map<String, dynamic>? ?? {};
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5F4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _iconFor(service['icon_name'] ?? category['icon_name']),
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'] ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        provider['business_name'] ?? 'Provider',
                        style: const TextStyle(
                          color: _mutedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Rs ${service['base_charge'] ?? 0}',
                    style: const TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoChip(
                  icon: Icons.category_outlined,
                  label: category['name'] ?? 'Service',
                ),
                InfoChip(
                  icon: Icons.workspace_premium_outlined,
                  label: '${provider['experience_years'] ?? 0} yrs',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service['description'] ?? '',
              style: const TextStyle(color: _inkColor, height: 1.35),
            ),
            const SizedBox(height: 10),
            IconLine(
              icon: Icons.location_on_outlined,
              text: service['service_area'] ?? service['city'] ?? '',
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
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

