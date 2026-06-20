part of fixmate_app;

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.text,
    this.icon = Icons.inbox_outlined,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: _primaryColor, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

