import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../widgets/glass_feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class LocationController extends GetxController {
  final AddressRepository addressRepository;

  LocationController({required this.addressRepository});

  final Rx<Position?> position = Rx<Position?>(null);
  final Rx<LocationPermission> permissionStatus = LocationPermission.denied.obs;
  final RxDouble distanceKm = 0.0.obs;
  final RxDouble currentShippingCost = AppConstants.flatShippingCost.obs;
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

  void loadAddresses() {
    var list = addressRepository.getAddresses(currentUserId);

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
      addressRepository.saveAddress(defaultAddr);
      list = [defaultAddr];
    }

    addresses.assignAll(list);

    if (list.isNotEmpty) {
      final primary = addressRepository.getPrimaryAddress(currentUserId);
      selectedAddress.value = primary ?? list.first;
      // Perbarui ongkir
      if (selectedAddress.value != null) {
        final subtotal = Get.isRegistered<CartController>()
            ? Get.find<CartController>().getTotalPrice()
            : 0.0;
        updateDistanceAndShipping(selectedAddress.value!, subtotal);
      }
    }
  }

  /// Meminta izin lokasi dan mengambil koordinat terkini via Geolocator (NT-08, TC-18, TC-19, TC-20)
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
          title: 'Izin Lokasi Dibutuhkan',
          message:
              'Wiji Bumi menggunakan koordinat lokasi Anda untuk menghitung jarak pengiriman dari kebun dan tarif ongkos kirim secara otomatis.',
          confirmText: 'Izinkan',
        );

        if (agree == true) {
          perm = await LocationService.requestPermission();
          permissionStatus.value = perm;
        } else {
          isLoadingLocation.value = false;
          return null;
        }
      }

      if (perm == LocationPermission.deniedForever) {
        isLoadingLocation.value = false;
        final openApp = await GlassFeedback.showConfirmDialog(
          context: context,
          title: 'Izin Lokasi Ditolak Permanen',
          message:
              'Izin lokasi telah dinonaktifkan di pengaturan sistem Android. Silakan buka Pengaturan Aplikasi untuk mengaktifkan izin.',
          confirmText: 'Pengaturan Aplikasi',
        );
        if (openApp == true) {
          await LocationService.openAppSettings();
        }
        return null;
      }

      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await LocationService.getCurrentPosition();
        if (pos != null) {
          position.value = pos;
          distanceKm.value = LocationService.calculateDistanceKm(
            startLatitude: pos.latitude,
            startLongitude: pos.longitude,
          );
          GlassFeedback.showSnackbar(
            title: 'Lokasi Terdeteksi',
            message:
                'Koordinat: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)} (Jarak: ${distanceKm.value.toStringAsFixed(1)} km)',
          );
          return pos;
        }
      }
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Mengambil Lokasi',
        message: 'Menggunakan tarif standar ongkir.',
        isError: true,
      );
    } finally {
      isLoadingLocation.value = false;
    }
    return null;
  }

  void updateDistanceAndShipping(AddressModel address, double subtotal) {
    if (address.latitude != 0 && address.longitude != 0) {
      distanceKm.value = LocationService.calculateDistanceKm(
        startLatitude: address.latitude,
        startLongitude: address.longitude,
      );
      currentShippingCost.value = LocationService.calculateShippingCost(
        distanceKm: distanceKm.value,
        subtotal: subtotal,
      );
    } else {
      distanceKm.value = 0.0;
      currentShippingCost.value = LocationService.calculateShippingCost(
        distanceKm: null,
        subtotal: subtotal,
      );
    }
  }

  Future<void> saveAddress(AddressModel address) async {
    final validAddress = address.copyWith(userId: currentUserId);
    await addressRepository.saveAddress(validAddress);
    loadAddresses();
    selectedAddress.value = validAddress;

    final subtotal = Get.isRegistered<CartController>()
        ? Get.find<CartController>().getTotalPrice()
        : 0.0;
    updateDistanceAndShipping(validAddress, subtotal);

    GlassFeedback.showSnackbar(
      title: 'Alamat Berhasil Disimpan',
      message: '${validAddress.recipientName} dipilih sebagai alamat pengiriman.',
    );
  }

  Future<void> deleteAddress(String id) async {
    await addressRepository.deleteAddress(id);
    loadAddresses();
    if (selectedAddress.value?.id == id) {
      selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
    }
    GlassFeedback.showSnackbar(
      title: 'Alamat Dihapus',
      message: 'Alamat telah dihapus dari daftar.',
    );
  }
}
