import 'package:get/get.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../widgets/glass_feedback.dart';
import 'auth_controller.dart';

class NotificationController extends GetxController {
  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final RxBool permissionGranted = false.obs;

  int get unreadCount => reminders.where((r) => !r.isRead).length;

  String get _currentUserId {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.id ?? 'guest';
    }
    return 'guest';
  }

  @override
  void onInit() {
    super.onInit();
    checkPermission();
    loadReminders();
  }

  Future<void> checkPermission() async {
    permissionGranted.value = await NotificationService.requestPermission();
  }

  Future<void> loadReminders() async {
    try {
      final list = await DatabaseHelper.getReminders(_currentUserId);
      reminders.assignAll(list);
    } catch (_) {}
  }

  Future<void> createReminder({
    required String title,
    required DateTime scheduledDate,
  }) async {
    final id = 'rem_${DateTime.now().millisecondsSinceEpoch}';
    final reminder = ReminderModel(
      id: id,
      userId: _currentUserId,
      title: title,
      scheduledAt: scheduledDate,
      isActive: true,
    );

    // 1. Simpan ke SQLite
    await DatabaseHelper.saveReminder(reminder);
    await loadReminders();

    // 2. Jadwalkan Notifikasi Lokal via zonedSchedule
    final notifId = id.hashCode & 0x7FFFFFFF;
    await NotificationService.scheduleNotification(
      id: notifId,
      title: '🌿 Waktunya Belanja Sayur & Buah!',
      body: 'Pengingat Wiji Bumi: $title',
      scheduledDate: scheduledDate,
    );

    // 3. Picu Notifikasi Immediate bahwa pengingat telah berhasil dijadwalkan
    await NotificationService.showImmediateNotification(
      id: (notifId + 1) & 0x7FFFFFFF,
      title: 'Pengingat Dijadwalkan!',
      body: 'Jadwal belanja "$title" berhasil diatur untuk ${scheduledDate.day}/${scheduledDate.month} ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}.',
    );

    GlassFeedback.showSnackbar(
      title: 'Pengingat Disimpan',
      message: 'Jadwal belanja rutin berhasil diatur.',
    );
  }

  /// Menambahkan notifikasi aktivitas pesanan ke database lokal SQLite dan memicu notifikasi visual
  Future<void> addOrderNotification({
    required String title,
    required String status,
    required String orderNumber,
    String? message,
    String? orderId,
  }) async {
    final id = 'ord_notif_${DateTime.now().millisecondsSinceEpoch}';
    final notifTitle = '$title ($status)';
    final detailBody = message ?? 'Pesanan No. $orderNumber status saat ini: $status.';
    final reminder = ReminderModel(
      id: id,
      userId: _currentUserId,
      title: notifTitle,
      message: detailBody,
      scheduledAt: DateTime.now(),
      isActive: true,
      isRead: false,
    );

    // 1. Simpan ke SQLite dan perbarui state di memori
    await DatabaseHelper.saveReminder(reminder);
    await loadReminders();

    // 2. Tampilkan notifikasi segera di bilah status sistem
    try {
      final notifId = id.hashCode & 0x7FFFFFFF;
      await NotificationService.showImmediateNotification(
        id: notifId,
        title: title,
        body: detailBody,
        payload: orderId,
      );
    } catch (_) {}
  }

  /// Menandai satu item notifikasi sebagai sudah dibaca
  Future<void> markAsRead(String id) async {
    final index = reminders.indexWhere((r) => r.id == id);
    if (index != -1 && !reminders[index].isRead) {
      reminders[index].isRead = true;
      reminders.refresh();
      await DatabaseHelper.markReminderAsRead(id, true);
    }
  }

  /// Menandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    bool hasUnread = false;
    for (var r in reminders) {
      if (!r.isRead) {
        r.isRead = true;
        hasUnread = true;
      }
    }
    if (hasUnread) {
      reminders.refresh();
      await DatabaseHelper.markAllRemindersAsRead(_currentUserId);
      GlassFeedback.showSnackbar(
        title: 'Semua Dibaca',
        message: 'Semua notifikasi telah ditandai sudah dibaca.',
      );
    }
  }

  Future<void> toggleReminder(String id, bool active) async {
    final reminder = await DatabaseHelper.getReminderById(id);
    if (reminder != null) {
      reminder.isActive = active;
      await DatabaseHelper.saveReminder(reminder);
      final notifId = id.hashCode & 0x7FFFFFFF;
      if (active) {
        await NotificationService.scheduleNotification(
          id: notifId,
          title: '🌿 Waktunya Belanja Sayur & Buah!',
          body: 'Pengingat Wiji Bumi: ${reminder.title}',
          scheduledDate: reminder.scheduledAt,
        );
      } else {
        await NotificationService.cancelNotification(notifId);
      }
      await loadReminders();
    }
  }

  Future<void> deleteReminder(String id) async {
    final notifId = id.hashCode & 0x7FFFFFFF;
    await NotificationService.cancelNotification(notifId);
    await DatabaseHelper.deleteReminder(id);
    await loadReminders();
    GlassFeedback.showSnackbar(
      title: 'Pengingat Dihapus',
      message: 'Jadwal pengingat telah dibatalkan.',
    );
  }
}
