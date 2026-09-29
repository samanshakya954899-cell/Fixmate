part of fixmate_app;

class AppHero extends StatelessWidget {
  const AppHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryColor, Color(0xFF4344B8), _navyColor],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: .18)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x385B5CE2),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -26,
              top: 18,
              child: Transform.rotate(
                angle: -0.35,
                child: Container(
                  width: 150,
                  height: 34,
                  color: Colors.white.withValues(alpha: .08),
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: -52,
              child: Container(
                width: 142,
                height: 142,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .07),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: .08)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Color(0x26FFFFFF),
                          blurRadius: 8,
                          offset: Offset(-3, -3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 31),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xE6FFFFFF),
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
