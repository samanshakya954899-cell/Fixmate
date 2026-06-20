part of fixmate_app;

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

Color _statusColor(String status) {
  switch (status) {
    case 'accepted':
      return const Color(0xFF1F7A4D);
    case 'in_progress':
      return const Color(0xFFB65C00);
    case 'completed':
      return const Color(0xFF3559C7);
    case 'rejected':
      return const Color(0xFFC03535);
    default:
      return _accentColor;
  }
}

String _modeLabel(String mode) => mode == 'provider' ? 'Provider' : 'Customer';

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

