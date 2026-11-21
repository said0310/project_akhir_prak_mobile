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
        title: const Text('Pengaturan Pengingat'),
      ),
      body: Obx(() {
        final reminders = notifController.reminders;

        if (reminders.isEmpty) {
          return EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Belum Ada Pengingat',
            message: 'Atur pengingat belanja sayur rutin agar dapur Anda selalu terisi bahan makanan segar.',
            action: CustomButton(
              text: '+ Tambah Jadwal Pengingat',
              width: 220,
              onPressed: _showAddReminderDialog,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          physics: const BouncingScrollPhysics(),
          itemCount: reminders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = reminders[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: DynamicGlassDecoration.cleanCard(radius: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.isActive ? WijiBumiColors.lightMint : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.isActive ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                      color: item.isActive ? WijiBumiColors.deepForest : WijiBumiColors.textMuted,
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: item.isActive ? WijiBumiColors.textPrimary : WijiBumiColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormatter.format(item.scheduledAt),
                          style: const TextStyle(fontSize: 11, color: WijiBumiColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: item.isActive,
                    activeColor: WijiBumiColors.freshLeaf,
                    onChanged: (val) {
                      notifController.toggleReminder(item.id, val);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: WijiBumiColors.error),
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
        backgroundColor: WijiBumiColors.deepForest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Tambah Pengingat'),
        onPressed: _showAddReminderDialog,
      ),
    );
  }
}
