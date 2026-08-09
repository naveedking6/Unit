/// Natural Urdu month names and date formatting.
/// Numbers are kept as standard readable digits (1250), per spec — not
/// converted to Urdu-Indic digits, so meter numbers stay unambiguous.
class UrduFormat {
  static const List<String> _months = [
    'جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون',
    'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر',
  ];

  static String monthName(int month) => _months[month - 1];

  static String monthYear(int year, int month) => '${monthName(month)} $year';

  static String fullDate(DateTime d) => '${d.day} ${monthName(d.month)} ${d.year}';
}
