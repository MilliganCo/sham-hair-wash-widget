const _russianMonthNames = <String>[
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String formatDateIso(DateTime date) {
  final normalized = dateOnly(date);
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '${normalized.year}-$month-$day';
}

DateTime? parseDateIso(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return dateOnly(DateTime.parse(value));
}

String formatDateRu(DateTime date) {
  final normalized = dateOnly(date);
  final day = normalized.day.toString().padLeft(2, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  return '$day.$month.${normalized.year}';
}

String formatDateLongRu(DateTime date) {
  final normalized = dateOnly(date);
  return '${normalized.day} ${_russianMonthNames[normalized.month - 1]} ${normalized.year}';
}
