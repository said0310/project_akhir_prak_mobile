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
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: WijiBumiColors.softSage, width: 1),
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
                        color: WijiBumiColors.deepForest,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _titleController,
                      hintText: 'Misal: Belanja sayur bayam & buah',
                      labelText: 'Judul Pengingat',
                      prefixIcon: Icons.alarm_outlined,
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
                        decoration: DynamicGlassDecoration.cleanCard(radius: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: WijiBumiColors.deepForest),
                            const SizedBox(width: 10),
                            Text(
                              'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}',
                              style: const TextStyle(fontSize: 13, color: WijiBumiColors.textPrimary),
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
                        decoration: DynamicGlassDecoration.cleanCard(radius: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: WijiBumiColors.deepForest),
                            const SizedBox(width: 10),
                            Text(
                              'Waktu: ${_selectedTime.format(context)}',
                              style: const TextStyle(fontSize: 13, color: WijiBumiColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal', style: TextStyle(color: WijiBumiColors.textMuted)),
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

                              final notifController = Get.find<NotificationController>();
                              notifController.createReminder(
                                title: _titleController.text.trim(),
                                scheduledDate: scheduledDateTime,
                              );

                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
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
    final dateFormatter = DateFormat('EEEE, dd MMM yyyy • HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Notifikasi & Pengingat'),
        actions: [
          Obx(() {
            final unread = notifController.unreadCount;
            if (unread == 0) return const SizedBox.shrink();
            return TextButton.icon(
              icon: const Icon(Icons.done_all_rounded, size: 16, color: WijiBumiColors.freshLeaf),
              label: const Text(
                'Tandai Dibaca',
                style: TextStyle(
                  color: WijiBumiColors.freshLeaf,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              onPressed: notifController.markAllAsRead,
            );
          }),
        ],
      ),
      body: Obx(() {
        final reminders = notifController.reminders;

        if (reminders.isEmpty) {
          return EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Belum Ada Notifikasi',
            message: 'Aktivitas pesanan dan jadwal pengingat belanja sayur Anda akan muncul di sini.',
            action: CustomButton(
              text: '+ Tambah Jadwal Pengingat',
              width: 220,
              onPressed: _showAddReminderDialog,
            ),
          );
        }

        final unreadCount = notifController.unreadCount;

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          physics: const BouncingScrollPhysics(),
          itemCount: reminders.length + (unreadCount > 0 ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            // Header Bar jika ada notifikasi belum dibaca
            if (unreadCount > 0 && index == 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: WijiBumiColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: WijiBumiColors.freshLeaf.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: WijiBumiColors.freshLeaf,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$unreadCount Belum Dibaca',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: WijiBumiColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: notifController.markAllAsRead,
                      child: const Text(
                        'Tandai semua sudah dibaca',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: WijiBumiColors.freshLeaf,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final actualIndex = unreadCount > 0 ? index - 1 : index;
            final item = reminders[actualIndex];
            final isOrderNotif = item.id.startsWith('ord_') || item.title.contains('Pesanan');
            final isUnread = !item.isRead;
            final messageText = item.message?.isNotEmpty == true
                ? item.message!
                : (isOrderNotif ? 'Aktivitas pesanan telah diperbarui.' : 'Jadwal pengingat belanja rutin.');

            return InkWell(
              onTap: () {
                if (isUnread) {
                  notifController.markAsRead(item.id);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isUnread
                        ? [
                            Colors.white.withOpacity(0.60),
                            const Color(0xFFD8EADA).withOpacity(0.44),
                          ]
                        : [
                            Colors.white.withOpacity(0.42),
                            const Color(0xFFD8EADA).withOpacity(0.28),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUnread
                        ? WijiBumiColors.freshLeaf.withOpacity(0.55)
                        : Colors.white.withOpacity(0.25),
                    width: isUnread ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isUnread
                          ? WijiBumiColors.freshLeaf.withOpacity(0.12)
                          : Colors.black.withOpacity(0.15),
                      blurRadius: isUnread ? 14 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ikon Notifikasi / Pengingat
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUnread
                            ? WijiBumiColors.lightMint
                            : (item.isActive ? WijiBumiColors.lightMint : Colors.grey.shade200),
                        shape: BoxShape.circle,
                        border: isUnread
                            ? Border.all(color: WijiBumiColors.freshLeaf, width: 1.2)
                            : null,
                      ),
                      child: Icon(
                        isOrderNotif
                            ? Icons.notifications_active_rounded
                            : (item.isActive ? Icons.alarm_on_rounded : Icons.alarm_off_rounded),
                        color: isOrderNotif
                            ? WijiBumiColors.deepForest
                            : (item.isActive ? WijiBumiColors.deepForest : WijiBumiColors.textMuted),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Konten: Judul, Isi Pesan Detail, & Waktu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                    color: WijiBumiColors.textCardDark,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: WijiBumiColors.freshLeaf,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Pesan Detail Notifikasi (Terbaca Jelas)
                          Text(
                            messageText,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                              color: WijiBumiColors.textCardDark.withOpacity(isUnread ? 0.90 : 0.70),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Tanggal & Waktu Notifikasi
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: WijiBumiColors.textCardDark.withOpacity(0.55),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  dateFormatter.format(item.scheduledAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: WijiBumiColors.textCardDark.withOpacity(0.60),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Aksi di sisi kanan:
                    // Untuk notifikasi pesanan: TIDAK ADA IKON HAPUS (rapi dan standar)
                    // Untuk pengingat rutin: tetap sediakan switch dan opsi hapus
                    if (!isOrderNotif) ...[
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Switch(
                            value: item.isActive,
                            activeColor: WijiBumiColors.freshLeaf,
                            onChanged: (val) {
                              notifController.toggleReminder(item.id, val);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: WijiBumiColors.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              notifController.deleteReminder(item.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: WijiBumiColors.deepForest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Tambah Pengingat'),
        onPressed: _showAddReminderDialog,
      ),
    );
  }
}
