import 'package:intl/intl.dart';

String formatLikes(int likes) {
  return NumberFormat.compact(locale: Intl.getCurrentLocale()).format(likes);
}

String formatDateShort(DateTime date) {
  // Ejemplo de fecha: 25 feb 2026
  return DateFormat('d MMM y', Intl.getCurrentLocale()).format(date);
}
