/// Formats a decimal amount string (e.g. "1234567.89") as Indian-grouped
/// rupees (e.g. "₹12,34,567.89"). No `intl` dependency - this app matches
/// the other three apps' minimal dependency footprint.
String formatRupees(String amount) {
  final value = double.tryParse(amount) ?? 0;
  final isNegative = value < 0;
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final wholePart = parts[0];
  final decimalPart = parts[1];

  return '${isNegative ? '-' : ''}₹${_groupIndian(wholePart)}.$decimalPart';
}

String _groupIndian(String wholePart) {
  if (wholePart.length <= 3) return wholePart;

  final lastThree = wholePart.substring(wholePart.length - 3);
  var remaining = wholePart.substring(0, wholePart.length - 3);
  final groups = <String>[];

  while (remaining.length > 2) {
    groups.insert(0, remaining.substring(remaining.length - 2));
    remaining = remaining.substring(0, remaining.length - 2);
  }
  if (remaining.isNotEmpty) {
    groups.insert(0, remaining);
  }

  return '${groups.join(',')},$lastThree';
}

String formatDateTimeReadable(DateTime dateTime) {
  final local = dateTime.toLocal();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${local.day} ${months[local.month - 1]} ${local.year}, $hour:$minute $period';
}

String formatDateShort(DateTime dateTime) {
  final local = dateTime.toLocal();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}
