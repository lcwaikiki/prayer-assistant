enum CalendarWeekStart {
  sunday,
  monday;

  static CalendarWeekStart fromName(String? name) {
    return CalendarWeekStart.values.firstWhere(
      (value) => value.name == name,
      orElse: () => CalendarWeekStart.monday,
    );
  }

  /// Calculates leading blank cells for a month grid starting on [firstDate].
  int leadingBlanks(DateTime firstDate) {
    return this == CalendarWeekStart.sunday
        ? firstDate.weekday % 7
        : (firstDate.weekday - 1) % 7;
  }

  /// Returns weekday numbers in display order (1=Mon..7=Sun).
  List<int> get weekdayOrder {
    return this == CalendarWeekStart.sunday
        ? const [7, 1, 2, 3, 4, 5, 6]
        : const [1, 2, 3, 4, 5, 6, 7];
  }
}
