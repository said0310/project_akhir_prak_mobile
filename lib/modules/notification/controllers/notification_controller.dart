import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/reminder_model.dart';
import '../../../storage/hive_service.dart';
import '../../../widgets/glass_feedback.dart';
import '../../auth/controllers/auth_controller.dart';

class NotificationController extends GetxController {
  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final RxBool permissionGranted = false.obs;

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

  void loadReminders() {
    final list = HiveService.reminderBox.values
        .where((r) => r.userId == _currentUserId)
        .toList();
    reminders.assignAll(list);
  }

  /// Buat Pengingat Belanja Terjadwal (NT-05, NT-06, NT-07)
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

    // 1. Simpan ke Hive
    await HiveService.reminderBox.put(id, reminder);
    loadReminders();

    // 2. Jadwalkan Notifikasi Lokal via zonedSchedule
    final notifId = id.hashCode & 0x7FFFFFFF;
    await NotificationService.scheduleNotification(
      id: notifId,
      title: '🌿 Waktunya Belanja Sayur & Buah!',
      body: 'Pengingat Wiji Bumi: $title',
      scheduledDate: scheduledDate,
    );

    // 3. Picu Notifikasi Immediate bahwa pengingat telah berhasil dijadwalkan (NT-04)
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

  /// Toggle status aktif pengingat
  Future<void> toggleReminder(String id, bool active) async {
    final reminder = HiveService.reminderBox.get(id);
    if (reminder != null) {
      reminder.isActive = active;
      await HiveService.reminderBox.put(id, reminder);
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
      loadReminders();
    }
  }

  /// Hapus pengingat (NT-07)
  Future<void> deleteReminder(String id) async {
    final notifId = id.hashCode & 0x7FFFFFFF;
    await NotificationService.cancelNotification(notifId);
    await HiveService.reminderBox.delete(id);
    loadReminders();

    GlassFeedback.showSnackbar(
      title: 'Pengingat Dihapus',
      message: 'Jadwal notifikasi telah dibatalkan.',
    );
  }
}
