class CalendarUtils {
  static List<({int day, bool current})> getDaysInMonthGrid(
    int year,
    int month,
  ) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    DateTime startDate = _getStartOfWeek(firstDayOfMonth);
    DateTime endDate = _getEndOfWeek(lastDayOfMonth);

    List<({int day, bool current})> days = [];
    for (
      DateTime currentDate = startDate;
      !currentDate.isAfter(endDate);
      currentDate = currentDate.add(const Duration(days: 1))
    ) {
      days.add((day: currentDate.day, current: currentDate.month == month));
    }

    return days;
  }

  static DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  static DateTime _getEndOfWeek(DateTime date) {
    int daysToAdd = DateTime.sunday - date.weekday;
    return DateTime(date.year, date.month, date.day + daysToAdd);
  }
}
