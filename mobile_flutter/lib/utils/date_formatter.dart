String formatTime(DateTime dateTime) {
  final now = DateTime.now();

  final isToday =
      now.year == dateTime.year &&
      now.month == dateTime.month &&
      now.day == dateTime.day;

  if (isToday) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }

  final isYesterday =
      now.subtract(const Duration(days: 1)).day == dateTime.day &&
      now.month == dateTime.month &&
      now.year == dateTime.year;

  if (isYesterday) {
    return "Yesterday";
  }

  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}