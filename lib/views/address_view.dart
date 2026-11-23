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
        backgroundColor: WijiBumiColors.deepForest,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pilih & Form Alamat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isAdding ? Icons.close : Icons.add_location_alt_outlined, color: Colors.white),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kartu "Gunakan Lokasi Saya"
            InkWell(
              onTap: _onUseCurrentLocation,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: DynamicGlassDecoration.glassCard(radius: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.24), width: 1.0),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFFA7F3D0),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deteksi Lokasi GPS Saya',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: WijiBumiColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Gunakan titik koordinat saat ini untuk hitung jarak kebun',
                            style: TextStyle(
                              fontSize: 12,
                              color: WijiBumiColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: WijiBumiColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 2. Formulir Tambah Alamat (Bisa dibuka/tutup)
            if (_isAdding) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: DynamicGlassDecoration.glassCard(radius: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Form Tambah Alamat Baru',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Nama Penerima',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _recipientController,
                        hintText: 'Nama lengkap penerima',
                        prefixIcon: Icons.person_outline_rounded,
                        textColor: WijiBumiColors.textPrimary,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Nama tidak boleh kosong';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Nomor Telepon',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: 'Nomor telepon aktif',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textColor: WijiBumiColors.textPrimary,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Telepon tidak boleh kosong';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Alamat Lengkap (Jalan, No. Rumah, RT/RW)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _addressController,
                        hintText: 'Misal: Jl. Kemang Raya No. 12',
                        prefixIcon: Icons.home_outlined,
                        maxLines: 2,
                        textColor: WijiBumiColors.textPrimary,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Alamat tidak boleh kosong';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kecamatan',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _districtController,
                                  hintText: 'Kecamatan',
                                  textColor: WijiBumiColors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kota / Kab',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _cityController,
                                  hintText: 'Kota',
                                  textColor: WijiBumiColors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Info Titik Koordinat GPS
                      if (_latitude != 0.0 && _longitude != 0.0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.24)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.gps_fixed_rounded, size: 16, color: Color(0xFFA7F3D0)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'GPS: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFA7F3D0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Switch Jadikan Alamat Utama
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jadikan Alamat Utama',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
                          ),
                          Switch(
                            value: _isPrimary,
                            activeColor: WijiBumiColors.freshLeaf,
                            onChanged: (val) {
                              setState(() {
                                _isPrimary = val;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      CustomButton(
                        text: 'Simpan Alamat Baru',
                        onPressed: _onSaveAddress,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],

            // 3. Daftar Alamat Tersimpan
            const Text(
              'Alamat Tersimpan',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: WijiBumiColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Obx(() {
              final addresses = locationController.addresses;

              if (addresses.isEmpty) {
                return const EmptyState(
                  icon: Icons.location_off_outlined,
                  title: 'Belum Ada Alamat',
                  message: 'Silakan tambahkan alamat pengiriman dengan menekan tombol "+" di atas.',
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final addr = addresses[index];
                  final isSelected = locationController.selectedAddress.value?.id == addr.id;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                              width: 1.6,
                            ),
                          )
                        : DynamicGlassDecoration.glassCard(radius: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 20, color: Color(0xFFA7F3D0)),
                                const SizedBox(width: 8),
                                Text(
                                  addr.recipientName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: WijiBumiColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (addr.isPrimary)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white.withOpacity(0.24)),
                                ),
                                child: const Text(
                                  'Utama',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFA7F3D0),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Telp: ${addr.phone}',
                          style: const TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          addr.fullAddress,
                          style: const TextStyle(fontSize: 12.5, color: WijiBumiColors.textSecondary, height: 1.3),
                        ),
                        Text(
                          '${addr.district}, ${addr.city}',
                          style: const TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Colors.white.withOpacity(0.14), height: 1),
                        ),

                        // Tombol Aksi: Pilih Alamat & Hapus
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isSelected)
                              const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 16, color: WijiBumiColors.freshLeaf),
                                  SizedBox(width: 6),
                                  Text(
                                    'Alamat Terpilih',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: WijiBumiColors.freshLeaf,
                                    ),
                                  ),
                                ],
                              )
                            else
                              TextButton(
                                onPressed: () {
                                  final subtotal = Get.isRegistered<ShopController>()
                                      ? Get.find<ShopController>().getTotalPrice()
                                      : 0.0;
                                  locationController.selectAddress(addr, subtotal);
                                  if (Get.previousRoute == AppRoutes.CHECKOUT) {
                                    Get.back();
                                  }
                                },
                                child: const Text(
                                  'Gunakan Alamat Ini',
                                  style: TextStyle(
                                    color: WijiBumiColors.deepForest,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),

                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: WijiBumiColors.error),
                              tooltip: 'Hapus Alamat',
                              onPressed: () {
                                locationController.deleteAddress(addr.id);
                              },
                            ),
                          ],
                        ),
                      ],
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
