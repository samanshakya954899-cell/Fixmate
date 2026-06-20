part of fixmate_app;

class IconLine extends StatelessWidget {
  const IconLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _primaryColor),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text.isEmpty ? 'Not provided' : text,
            style: const TextStyle(
              color: _mutedColor,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

