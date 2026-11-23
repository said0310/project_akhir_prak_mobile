import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../app.dart';
import '../models/models.dart';
import '../controllers/location_controller.dart';
import '../controllers/shop_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_feedback.dart';
import '../widgets/google_map_widget.dart';
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
  void initState() {
    super.initState();
    if (Get.isRegistered<LocationController>()) {
      _recipientController.text = Get.find<LocationController>().currentUserName;
    }
  }

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
      });

      // Panggil Google Geocoding API untuk mengisi field alamat secara otomatis
      final geocodeResult = await locationController.fetchAddressFromCoordinates(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      if (geocodeResult != null && mounted) {
        setState(() {
          if (_addressController.text.isEmpty) {
            _addressController.text = geocodeResult.streetName;
          }
          if (_districtController.text.isEmpty) {
            _districtController.text = geocodeResult.sublocality.isNotEmpty
                ? geocodeResult.sublocality
                : 'Condongcatur, Depok';
          }
          if (_cityController.text.isEmpty) {
            _cityController.text = geocodeResult.city.isNotEmpty
                ? geocodeResult.city
                : 'Sleman';
          }
        });
      } else if (mounted) {
        // Fallback jika Geocoding gagal
        setState(() {
          if (_cityController.text.isEmpty) _cityController.text = 'Sleman';
          if (_districtController.text.isEmpty) _districtController.text = 'Condongcatur';
        });
      }
    }
  }

  /// Pilih lokasi langsung dari peta dengan mengetuk atau menggeser titik
  void _onMapTap(LatLng position) async {
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });

    // Auto-isi form dari koordinat yang diketuk / digeser via Geocoding
    final locationController = Get.find<LocationController>();
    final result = await locationController.fetchAddressFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (result != null && mounted) {
      setState(() {
        _addressController.text = result.streetName;
        if (result.sublocality.isNotEmpty) {
          _districtController.text = result.sublocality;
        }
        if (result.city.isNotEmpty) {
          _cityController.text = result.city;
        }
      });
      GlassFeedback.showSnackbar(
        title: 'Titik Lokasi Terpilih',
        message: '${result.streetName}, ${result.sublocality}',
      );
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
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFA7F3D0).withOpacity(0.4), width: 1.2),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFFA7F3D0),
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Obx(() {
                            final pos = locationController.position.value;
                            if (locationController.isLoadingLocation.value) {
                              return const Text(
                                'Mendeteksi posisi satelit...',
                                style: TextStyle(fontSize: 11, color: Color(0xFFC8DDD0)),
                              );
                            }
                            if (pos != null) {
                              return Text(
                                'Terdeteksi: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFFA7F3D0), fontWeight: FontWeight.bold),
                              );
                            }
                            return const Text(
                              'Sentuh untuk mengisi koordinat secara otomatis',
                              style: TextStyle(fontSize: 11, color: Color(0xFFC8DDD0)),
                            );
                          }),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFC8DDD0)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Form Tambah Alamat Baru
            if (_isAdding) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: DynamicGlassDecoration.glassCard(radius: 16),
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
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
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
                        textColor: Colors.white,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama penerima wajib diisi' : null,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: '08xxxxxxxxxx',
                        labelText: 'Nomor Telepon',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        textColor: Colors.white,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nomor telepon wajib diisi' : null,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _addressController,
                        hintText: 'Alamat Lengkap (Jalan, No. Rumah, RT/RW)',
                        labelText: 'Alamat Rumah / Kantor',
                        maxLines: 2,
                        prefixIcon: Icons.home_outlined,
                        textColor: Colors.white,
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
                              textColor: Colors.white,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Kecamatan wajib' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: _cityController,
                              hintText: 'Kota/Kabupaten',
                              labelText: 'Kota',
                              textColor: Colors.white,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Kota wajib' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.20)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.pin_drop_outlined, size: 18, color: Color(0xFFA7F3D0)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _latitude != 0.0
                                    ? 'Koordinat: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}'
                                    : 'Koordinat belum diset (Bisa gunakan tombol GPS di atas)',
                                style: const TextStyle(fontSize: 11, color: Color(0xFFC8DDD0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ─── Google Maps: Pilih Lokasi dari Peta ───────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '📍 Geser / Pilih Lokasi di Peta',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (_latitude != 0)
                            Text(
                              '(${_latitude.toStringAsFixed(3)}, ${_longitude.toStringAsFixed(3)})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFA7F3D0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Geser layar atau ketuk titik di peta untuk memilih lokasi pengiriman.',
                        style: TextStyle(fontSize: 11, color: Color(0xFFC8DDD0)),
                      ),
                      const SizedBox(height: 8),
                      GoogleMapWidget(
                        userLatitude: _latitude != 0.0 ? _latitude : -7.7600,
                        userLongitude: _longitude != 0.0 ? _longitude : 110.4080,
                        userMarkerTitle: 'Titik Pengiriman',
                        userMarkerSnippet: 'Lokasi terpilih',
                        height: 250,
                        showStoreMarker: true,
                        showPolyline: _latitude != 0.0,
                        isPickerMode: true,
                        selectedBranch: locationController.selectedStore.value,
                        onBranchChanged: (branch) {
                          final subtotal = Get.isRegistered<ShopController>()
                              ? Get.find<ShopController>().getTotalPrice()
                              : 0.0;
                          locationController.setStoreBranch(branch, subtotal);
                        },
                        onMapTap: _onMapTap,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: _isPrimary,
                            activeColor: const Color(0xFFA7F3D0),
                            checkColor: const Color(0xFF142117),
                            onChanged: (val) {
                              setState(() {
                                _isPrimary = val ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Jadikan alamat pengiriman utama',
                            style: TextStyle(fontSize: 13, color: Colors.white),
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
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFFA7F3D0)),
                  label: const Text('Tambah Baru', style: TextStyle(color: Color(0xFFA7F3D0), fontWeight: FontWeight.bold)),
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
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFA7F3D0) : Colors.white.withOpacity(0.28),
                          width: isSelected ? 1.6 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.20),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? const Color(0xFFA7F3D0) : Colors.white.withOpacity(0.40),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                addr.recipientName,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${addr.phone})',
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFFC8DDD0)),
                              ),
                              const Spacer(),
                              if (addr.isPrimary || isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    isSelected ? 'Terpilih' : 'Utama',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFA7F3D0),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            addr.fullAddress,
                            style: const TextStyle(fontSize: 13, color: Color(0xFFC8DDD0), height: 1.35),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${addr.district}, ${addr.city}',
                            style: TextStyle(fontSize: 12, color: const Color(0xFFC8DDD0).withOpacity(0.85)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.near_me_outlined, size: 14, color: Color(0xFFA7F3D0)),
                                  const SizedBox(width: 4),
                                  Text(
                                    addr.latitude != 0
                                        ? 'GPS: ${addr.latitude.toStringAsFixed(3)}, ${addr.longitude.toStringAsFixed(3)}'
                                        : 'Tanpa GPS (Tarif Flat Rp 10.000)',
                                    style: const TextStyle(fontSize: 11.5, color: Color(0xFFA7F3D0), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              if (list.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFCA5A5)),
                                  onPressed: () async {
                                    final confirm = await GlassFeedback.showConfirmDialog(
                                      context: context,
                                      title: 'Hapus Alamat?',
                                      message: 'Apakah Anda yakin ingin menghapus alamat ini?',
                                      confirmText: 'Hapus',
                                      isDestructive: true,
                                    );
                                    if (confirm == true) {
                                      locationController.deleteAddress(addr.id);
                                    }
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
