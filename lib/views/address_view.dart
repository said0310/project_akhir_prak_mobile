import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../models/models.dart';
import '../controllers/location_controller.dart';
import '../controllers/shop_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  bool _isAdding = false;
  final _formKey = GlobalKey<FormState>();

  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isPrimary = true;

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _onUseCurrentLocation() async {
    final locationController = Get.find<LocationController>();
    final pos = await locationController.fetchCurrentLocation(context);
    if (pos != null) {
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        if (_cityController.text.isEmpty) _cityController.text = 'Jakarta Selatan';
        if (_districtController.text.isEmpty) _districtController.text = 'Mampang Prapatan';
      });
    }
  }

  void _onSaveAddress() async {
    if (_formKey.currentState?.validate() ?? false) {
      final locationController = Get.find<LocationController>();
      final newAddress = AddressModel(
        id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
        userId: locationController.currentUserId,
        recipientName: _recipientController.text.trim(),
        phone: _phoneController.text.trim(),
        fullAddress: _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty ? 'Jakarta Selatan' : _cityController.text.trim(),
        district: _districtController.text.trim().isEmpty ? 'Mampang Prapatan' : _districtController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        isPrimary: _isPrimary,
      );

      await locationController.saveAddress(newAddress);

      if (Get.isRegistered<ShopController>()) {
        locationController.updateDistanceAndShipping(
          newAddress,
          Get.find<ShopController>().getTotalPrice(),
        );
      }

      setState(() {
        _isAdding = false;
        _recipientController.clear();
        _phoneController.clear();
        _addressController.clear();
        _cityController.clear();
        _districtController.clear();
        _latitude = 0.0;
        _longitude = 0.0;
        _isPrimary = true;
      });

      if (Get.previousRoute == AppRoutes.CHECKOUT && mounted) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Pilih & Form Alamat'),
        actions: [
          IconButton(
            icon: Icon(_isAdding ? Icons.close : Icons.add_location_alt_outlined),
            tooltip: _isAdding ? 'Tutup Formulir' : 'Tambah Alamat',
            onPressed: () {
              setState(() {
                _isAdding = !_isAdding;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kartu Tombol Kaca "Gunakan Lokasi Saya"
            InkWell(
              onTap: _onUseCurrentLocation,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: WijiBumiColors.lightMint,
                        shape: BoxShape.circle,
                        border: Border.all(color: WijiBumiColors.freshLeaf, width: 1.2),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: WijiBumiColors.deepForest,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gunakan Lokasi GPS Saya',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: WijiBumiColors.deepForest,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Obx(() {
                            final pos = locationController.position.value;
                            if (locationController.isLoadingLocation.value) {
                              return const Text(
                                'Mendeteksi posisi satelit...',
                                style: TextStyle(fontSize: 11, color: WijiBumiColors.textMuted),
                              );
                            }
                            if (pos != null) {
                              return Text(
                                'Terdeteksi: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 11, color: WijiBumiColors.freshLeaf, fontWeight: FontWeight.bold),
                              );
                            }
                            return const Text(
                              'Sentuh untuk mengisi koordinat secara otomatis',
                              style: TextStyle(fontSize: 11, color: WijiBumiColors.textMuted),
                            );
                          }),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: WijiBumiColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Form Tambah Alamat Baru
            if (_isAdding) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: DynamicGlassDecoration.cleanCard(radius: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Formulir Alamat Baru',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: WijiBumiColors.deepForest),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              setState(() {
                                _isAdding = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _recipientController,
                        hintText: 'Nama Penerima (Misal: Sari Lestari)',
                        labelText: 'Nama Penerima',
                        prefixIcon: Icons.person_outline,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama penerima wajib diisi' : null,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: '08xxxxxxxxxx',
                        labelText: 'Nomor Telepon',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nomor telepon wajib diisi' : null,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _addressController,
                        hintText: 'Alamat Lengkap (Jalan, No. Rumah, RT/RW)',
                        labelText: 'Alamat Rumah / Kantor',
                        maxLines: 2,
                        prefixIcon: Icons.home_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Alamat lengkap wajib diisi' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _districtController,
                              hintText: 'Kecamatan',
                              labelText: 'Kecamatan',
                              validator: (v) => v == null || v.trim().isEmpty ? 'Kecamatan wajib' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: _cityController,
                              hintText: 'Kota/Kabupaten',
                              labelText: 'Kota',
                              validator: (v) => v == null || v.trim().isEmpty ? 'Kota wajib' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: WijiBumiColors.lightMint.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: WijiBumiColors.softSage),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.pin_drop_outlined, size: 18, color: WijiBumiColors.deepForest),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _latitude != 0.0
                                    ? 'Koordinat: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}'
                                    : 'Koordinat belum diset (Bisa gunakan tombol GPS di atas)',
                                style: const TextStyle(fontSize: 11, color: WijiBumiColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: _isPrimary,
                            activeColor: WijiBumiColors.deepForest,
                            onChanged: (val) {
                              setState(() {
                                _isPrimary = val ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Jadikan alamat pengiriman utama',
                            style: TextStyle(fontSize: 13, color: WijiBumiColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Simpan & Gunakan Alamat',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: _onSaveAddress,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 3. Daftar Alamat Tersimpan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Alamat Pengiriman',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: WijiBumiColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18, color: WijiBumiColors.deepForest),
                  label: const Text('Tambah Baru', style: TextStyle(color: WijiBumiColors.deepForest, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    setState(() {
                      _isAdding = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            Obx(() {
              final list = locationController.addresses;

              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.location_off_outlined,
                  title: 'Belum Ada Alamat',
                  message: 'Tambahkan alamat pengiriman agar pesanan Anda dapat diantar.',
                  action: CustomButton(
                    text: '+ Tambah Alamat Sekarang',
                    width: 220,
                    height: 42,
                    onPressed: () {
                      setState(() {
                        _isAdding = true;
                      });
                    },
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final addr = list[index];
                  final isSelected = locationController.selectedAddress.value?.id == addr.id;

                  return InkWell(
                    onTap: () {
                      locationController.selectedAddress.value = addr;
                      if (Get.isRegistered<ShopController>()) {
                        locationController.updateDistanceAndShipping(
                          addr,
                          Get.find<ShopController>().getTotalPrice(),
                        );
                      }
                      if (Get.previousRoute == AppRoutes.CHECKOUT) {
                        Get.back();
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? WijiBumiColors.deepForest : WijiBumiColors.softSage.withOpacity(0.55),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: WijiBumiColors.deepForest.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? WijiBumiColors.deepForest : WijiBumiColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                addr.recipientName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: WijiBumiColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${addr.phone})',
                                style: const TextStyle(fontSize: 12, color: WijiBumiColors.textMuted),
                              ),
                              const Spacer(),
                              if (addr.isPrimary || isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: DynamicGlassDecoration.accentPill(
                                    radius: 6,
                                    fillColor: isSelected ? WijiBumiColors.deepForest : WijiBumiColors.lightMint,
                                    borderColor: isSelected ? WijiBumiColors.deepForest : WijiBumiColors.freshLeaf,
                                  ),
                                  child: Text(
                                    isSelected ? 'Terpilih' : 'Utama',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : WijiBumiColors.deepForest,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            addr.fullAddress,
                            style: const TextStyle(fontSize: 13, color: WijiBumiColors.textSecondary, height: 1.3),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${addr.district}, ${addr.city}',
                            style: const TextStyle(fontSize: 12, color: WijiBumiColors.textMuted),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.near_me_outlined, size: 14, color: WijiBumiColors.freshLeaf),
                                  const SizedBox(width: 4),
                                  Text(
                                    addr.latitude != 0
                                        ? 'GPS: ${addr.latitude.toStringAsFixed(3)}, ${addr.longitude.toStringAsFixed(3)}'
                                        : 'Tanpa GPS (Tarif Flat Rp 10.000)',
                                    style: const TextStyle(fontSize: 11, color: WijiBumiColors.textMuted),
                                  ),
                                ],
                              ),
                              if (list.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: WijiBumiColors.error),
                                  onPressed: () {
                                    locationController.deleteAddress(addr.id);
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
