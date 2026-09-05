/// Formats [amount] as a PKR price string with thousands separators.
///
/// e.g. 4500000 -> "PKR 4,500,000"; null -> "Price on request".
String formatPkr(num? amount) {
  if (amount == null) {
    return 'Price on request';
  }
  final digits = amount.round().toString();
  final negative = digits.startsWith('-');
  final body = negative ? digits.substring(1) : digits;

  final buffer = StringBuffer();
  for (int i = 0; i < body.length; i++) {
    buffer.write(body[i]);
    final remaining = body.length - 1 - i;
    if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
  }
  return 'PKR ${negative ? '-' : ''}$buffer';
}

/// Compact time label, e.g. "just now", "5m", "2h", "3d".
String relativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 30) return '${diff.inDays}d';
  return '${diff.inDays ~/ 30}mo';
}
