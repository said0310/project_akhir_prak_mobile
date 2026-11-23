import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_feedback.dart';
import '../controllers/notification_controller.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddReminderDialog() {
    _titleController.text = 'Belanja Sayur Mingguan';
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 8, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2F21).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text(
                      'Tambah Pengingat Belanja',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: WijiBumiColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _titleController,
                      hintText: 'Misal: Belanja sayur bayam & buah',
                      labelText: 'Judul Pengingat',
                      prefixIcon: Icons.alarm_outlined,
                      textColor: WijiBumiColors.textPrimary,
                    ),
                    const SizedBox(height: 14),

                    // Pemilih Tanggal
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: WijiBumiColors.lightMint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: WijiBumiColors.softSage),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFFA7F3D0)),
                            const SizedBox(width: 10),
                            Text(
                              'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}',
                              style: const TextStyle(fontSize: 13, color: WijiBumiColors.textPrimary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Pemilih Jam
                    InkWell(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            _selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: WijiBumiColors.lightMint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: WijiBumiColors.softSage),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFFA7F3D0)),
                            const SizedBox(width: 10),
                            Text(
                              'Waktu: ${_selectedTime.format(context)}',
                              style: const TextStyle(fontSize: 13, color: WijiBumiColors.textPrimary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.0,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'Jadwalkan',
                            height: 42,
                            onPressed: () {
                              if (_titleController.text.trim().isEmpty) {
                                GlassFeedback.showSnackbar(
                                  title: 'Judul Kosong',
                                  message: 'Silakan isi judul pengingat',
                                  isError: true,
                                );
                                return;
                              }

                              final scheduledDateTime = DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day,
                                _selectedTime.hour,
                                _selectedTime.minute,
                              );

                              if (scheduledDateTime.isBefore(DateTime.now())) {
                                GlassFeedback.showSnackbar(
                                  title: 'Waktu Tidak Valid',
                                  message: 'Waktu pengingat harus berada di masa mendatang',
                                  isError: true,
                                );
                                return;
                              }

                              final notifController = Get.find<NotificationController>();
                              notifController.createReminder(
                                title: _titleController.text.trim(),
                                scheduledDate: scheduledDateTime,
                              );

                              Navigator.pop(ctx);
                              GlassFeedback.showSnackbar(
                                title: 'Pengingat Dijadwalkan',
                                message: 'Notifikasi akan berbunyi sesuai jadwal yang dipilih',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifController = Get.find<NotificationController>();
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: WijiBumiColors.deepForest,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pengingat & Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm_rounded, color: Colors.white),
            tooltip: 'Tambah Pengingat',
            onPressed: _showAddReminderDialog,
          ),
        ],
      ),
      body: Obx(() {
        final reminders = notifController.reminders;

        if (reminders.isEmpty) {
          return EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Belum Ada Pengingat',
            message: 'Jadwalkan pengingat belanja sayur dan produk organik agar tidak kehabisan stok panen segar.',
            action: ElevatedButton(
              onPressed: _showAddReminderDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: WijiBumiColors.deepForest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Buat Pengingat Sekarang', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          physics: const BouncingScrollPhysics(),
          itemCount: reminders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = reminders[index];
            final isPast = item.scheduledAt.isBefore(DateTime.now());

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: DynamicGlassDecoration.glassCard(radius: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.isActive && !isPast
                          ? Colors.white.withOpacity(0.14)
                          : Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.isActive && !isPast
                            ? const Color(0xFFA7F3D0).withOpacity(0.5)
                            : Colors.white.withOpacity(0.14),
                      ),
                    ),
                    child: Icon(
                      item.isActive && !isPast
                          ? Icons.alarm_on_rounded
                          : Icons.alarm_off_rounded,
                      color: item.isActive && !isPast
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFC8DDD0),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: item.isActive && !isPast
                                ? WijiBumiColors.textPrimary
                                : WijiBumiColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: WijiBumiColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dateFormatter.format(item.scheduledAt),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: WijiBumiColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isPast) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Sudah Terlewat',
                              style: TextStyle(fontSize: 10, color: WijiBumiColors.textSecondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Toggle Aktif / Non-aktif
                  Switch(
                    value: item.isActive && !isPast,
                    activeColor: WijiBumiColors.freshLeaf,
                    onChanged: isPast
                        ? null
                        : (val) {
                            notifController.toggleReminder(item.id, val);
                          },
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: WijiBumiColors.error, size: 20),
                    tooltip: 'Hapus Pengingat',
                    onPressed: () {
                      notifController.deleteReminder(item.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderDialog,
        backgroundColor: WijiBumiColors.deepForest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Pengingat', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
