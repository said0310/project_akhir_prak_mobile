import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import '../services/location_service.dart';
import '../widgets/glass_feedback.dart';
import 'auth_controller.dart';
import 'shop_controller.dart';

class LocationController extends GetxController {
  final AddressRepository addressRepository;

  LocationController({AddressRepository? addressRepository})
      : addressRepository = addressRepository ?? AddressRepository();

  final Rx<Position?> position = Rx<Position?>(null);
  final Rx<LocationPermission> permissionStatus = LocationPermission.denied.obs;
  final RxDouble distanceKm = 0.0.obs;
  final RxDouble currentShippingCost = DatabaseHelper.flatShippingCost.obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoadingLocation = false.obs;

  String get currentUserId {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.id ?? 'user_1';
    }
    return 'user_1';
  }

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    var list = await addressRepository.getAddresses(currentUserId);

    // Jika belum ada alamat tersimpan sama sekali, sediakan 1 alamat awal default
    if (list.isEmpty) {
      final defaultAddr = AddressModel(
        id: 'addr_default_1',
        userId: currentUserId,
        recipientName: 'Sari Lestari',
        phone: '081234567890',
        fullAddress: 'Jl. Kemang Raya No. 12 RT 04/RW 02',
        city: 'Jakarta Selatan',
        district: 'Mampang Prapatan',
        latitude: -6.2520,
        longitude: 106.8290,
        isPrimary: true,
      );
      await addressRepository.saveAddress(defaultAddr);
      list = [defaultAddr];
    }

    addresses.assignAll(list);

    if (list.isNotEmpty) {
      final primary = await addressRepository.getPrimaryAddress(currentUserId);
      selectedAddress.value = primary ?? list.first;
      // Perbarui ongkir
      if (selectedAddress.value != null) {
        final subtotal = Get.isRegistered<ShopController>()
            ? Get.find<ShopController>().getTotalPrice()
            : 0.0;
        updateDistanceAndShipping(selectedAddress.value!, subtotal);
      }
    }
  }

  Future<Position?> fetchCurrentLocation(BuildContext context) async {
    isLoadingLocation.value = true;

    try {
      final serviceEnabled = await LocationService.isServiceEnabled();
      if (!serviceEnabled) {
        isLoadingLocation.value = false;
        final openSettings = await GlassFeedback.showConfirmDialog(
          context: context,
          title: 'Layanan Lokasi (GPS) Nonaktif',
          message:
              'Aplikasi membutuhkan GPS aktif untuk menghitung jarak ke penjual secara akurat. Aktifkan GPS sekarang?',
          confirmText: 'Buka Pengaturan',
        );
        if (openSettings == true) {
          await LocationService.openLocationSettings();
        }
        return null;
      }

      var perm = await LocationService.checkPermission();
      permissionStatus.value = perm;

      if (perm == LocationPermission.denied) {
        final agree = await GlassFeedback.showConfirmDialog(
          context: context,
          title: 'Izin Lokasi Diperlukan',
          message:
              'Wiji Bumi memerlukan akses lokasi untuk mendeteksi alamat pengiriman dan menghitung ongkos kirim ke rumah Anda.',
          confirmText: 'Izinkan',
        );

        if (agree != true) {
          isLoadingLocation.value = false;
          return null;
        }

        perm = await LocationService.requestPermission();
        permissionStatus.value = perm;
      }

      if (perm == LocationPermission.deniedForever) {
        isLoadingLocation.value = false;
        final openApp = await GlassFeedback.showConfirmDialog(
          context: context,
          title: 'Izin Lokasi Ditolak Permanen',
          message:
              'Anda telah menolak izin lokasi sebelumnya. Silakan aktifkan izin secara manual di pengaturan perangkat.',
          confirmText: 'Buka Pengaturan',
        );
        if (openApp == true) {
          await LocationService.openAppSettings();
        }
        return null;
      }

      final pos = await LocationService.getCurrentPosition();
      position.value = pos;

      if (pos != null) {
        GlassFeedback.showSnackbar(
          title: 'Lokasi Ditemukan',
          message: 'Koordinat GPS berhasil diperoleh.',
        );
      }
      return pos;
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Membaca Lokasi',
        message: e.toString(),
        isError: true,
      );
      return null;
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void updateDistanceAndShipping(AddressModel address, double subtotal) {
    if (address.latitude == 0 && address.longitude == 0) {
      distanceKm.value = 0.0;
      currentShippingCost.value = LocationService.calculateShippingCost(
        distanceKm: null,
        subtotal: subtotal,
      );
      return;
    }

    final dist = LocationService.calculateDistanceKm(
      startLatitude: address.latitude,
      startLongitude: address.longitude,
    );
    distanceKm.value = dist;
    currentShippingCost.value = LocationService.calculateShippingCost(
      distanceKm: dist,
      subtotal: subtotal,
    );
  }

  void selectAddress(AddressModel address, double subtotal) {
    selectedAddress.value = address;
    updateDistanceAndShipping(address, subtotal);
  }

  Future<void> addAddress(AddressModel address) async {
    await addressRepository.saveAddress(address);
    await loadAddresses();
    GlassFeedback.showSnackbar(
      title: 'Alamat Disimpan',
      message: 'Alamat pengiriman baru berhasil ditambahkan.',
    );
  }

  Future<void> saveAddress(AddressModel address) => addAddress(address);

  Future<void> deleteAddress(String id) async {
    await addressRepository.deleteAddress(id);
    await loadAddresses();
    GlassFeedback.showSnackbar(
      title: 'Alamat Dihapus',
      message: 'Alamat pengiriman telah dihapus.',
    );
  }
}
