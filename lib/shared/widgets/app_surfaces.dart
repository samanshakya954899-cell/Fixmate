part of fixmate_app;

/// The quiet, atmospheric canvas used behind every primary screen.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: _backgroundColor),
        const Positioned(
          top: -110,
          right: -90,
          child: _AmbientOrb(
            size: 280,
            colors: [Color(0x265B5CE2), Color(0x008B7CF6)],
          ),
        ),
        const Positioned(
          bottom: 20,
          left: -120,
          child: _AmbientOrb(
            size: 300,
            colors: [Color(0x1F23B7A4), Color(0x000E9F8A)],
          ),
        ),
        child,
      ],
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

/// A restrained glass surface: enough depth to feel tactile without adding
/// visual noise to information-heavy screens.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius = 24,
    this.tint = const Color(0xD9FFFFFF),
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x165B5CE2),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x99FFFFFF),
            blurRadius: 1,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white.withValues(alpha: .76),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SoftIconTile extends StatelessWidget {
  const SoftIconTile({
    super.key,
    required this.icon,
    this.color = _primaryColor,
    this.size = 48,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(size * .34),
        border: Border.all(color: Colors.white.withValues(alpha: .9)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .14),
            blurRadius: 18,
            offset: const Offset(6, 8),
          ),
          const BoxShadow(
            color: Color(0xE6FFFFFF),
            blurRadius: 10,
            offset: Offset(-5, -5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * .48),
    );
  }
}
