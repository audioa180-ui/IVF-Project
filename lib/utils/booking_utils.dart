
class BookingUtils {
  static const defaultClinic = 'Bloom IVF Center - Mumbai';

  static DateTime? parseTimeSlot(String slot) {
    try {
      final parts = slot.trim().split(' ');
      if (parts.length != 2) return null;

      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;

      var hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSlotAvailable(String slot, DateTime? date,
      {Duration buffer = const Duration(minutes: 30)}) {
    if (date == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected.isAfter(today)) return true;
    if (selected.isBefore(today)) return false;

    final slotTime = parseTimeSlot(slot);
    if (slotTime == null) return false;

    return slotTime.isAfter(now.add(buffer));
  }

  static List<String> availableSlots(List<String> slots, DateTime? date) {
    return slots.where((slot) => isSlotAvailable(slot, date)).toList();
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
