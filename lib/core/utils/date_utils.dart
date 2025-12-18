String getPostingDate() {
  final now = DateTime.now();

  const weekDays = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final weekday = weekDays[now.weekday % 7];
  final month = months[now.month - 1];

  final day = now.day.toString().padLeft(2, '0');
  final hour = now.hour.toString().padLeft(2, '0');
  final minute = now.minute.toString().padLeft(2, '0');
  final second = now.second.toString().padLeft(2, '0');

  // Timezone offset
  final offset = now.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final offsetHours =
      offset.inHours.abs().toString().padLeft(2, '0');
  final offsetMinutes =
      (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

  return "$weekday $month $day ${now.year} "
         "$hour:$minute:$second "
         "GMT$sign$offsetHours$offsetMinutes "
         "(${now.timeZoneName})";
}
