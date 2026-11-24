import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../services/location_service.dart';
import '../services/map_service.dart';
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

  /// Cabang Toko Terpilih (Sleman atau Bantul)
  final Rx<StoreBranch> selectedStore = StoreBranch.sleman.obs;
  final RxBool autoSelectNearestStore = false.obs;

  /// Jarak spesifik ke masing-masing cabang toko
  final RxDouble distanceToSlemanKm = 0.0.obs;
  final RxDouble distanceToBantulKm = 0.0.obs;

  /// Hasil reverse geocoding dari Google Maps API
  final Rx<GeocodingResult?> geocodingResult = Rx<GeocodingResult?>(null);

  /// Hasil jarak rute jalan dari Google Distance Matrix API
  final Rx<DistanceResult?> distanceResult = Rx<DistanceResult?>(null);

  /// Label jarak yang ditampilkan di UI (dari Google atau fallback Haversine)
  final RxString distanceLabel = ''.obs;

  String get currentUserId {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.id ?? 'user_1';
    }
    return 'user_1';
  }

  String get currentUserName {
    if (Get.isRegistered<AuthController>()) {
      final name = Get.find<AuthController>().currentUser.value?.name;
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }
    return 'Pelanggan';
  }

  @override
  void onInit() {
    super.onInit();
    try {
      if (Get.isRegistered<PrefService>()) {
        final saved = Get.find<PrefService>().selectedStoreId;
        if (saved == 'bantul') {
          selectedStore.value = StoreBranch.bantul;
        } else {
          selectedStore.value = StoreBranch.sleman;
        }
      }
    } catch (_) {}
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    var list = await addressRepository.getAddresses(currentUserId);

    // Jika belum ada alamat tersimpan sama sekali, sediakan 1 alamat awal default (Area Sleman/DIY)
    if (list.isEmpty) {
      final defaultAddr = AddressModel(
        id: 'addr_default_1',
        userId: currentUserId,
        recipientName: currentUserName,
        phone: '081234567890',
        fullAddress: 'Jl. Kaliurang Km 5.6 No. 18, Sleman, DIY',
        city: 'Sleman',
        district: 'Depok',
        latitude: -7.7620,
        longitude: 110.3800,
        isPrimary: true,
      );
      await addressRepository.saveAddress(defaultAddr);
      list = [defaultAddr];
    } else {
      // Perbarui otomatis jika data lokal lama masih tertulis template 'Sari Lestari'
      for (var i = 0; i < list.length; i++) {
        if (list[i].recipientName == 'Sari Lestari' ||
            list[i].recipientName == 'Sari' ||
            list[i].recipientName.isEmpty) {
          final updated = list[i].copyWith(recipientName: currentUserName);
          await addressRepository.saveAddress(updated);
          list[i] = updated;
        }
      }
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

  /// Hitung jarak ke cabang toko tertentu (dalam km)
  double calculateDistanceToBranch(
      StoreBranch branch, double userLat, double userLng) {
    if (userLat == 0 && userLng == 0) return 0.0;
    return LocationService.calculateDistanceKm(
      startLatitude: userLat,
      startLongitude: userLng,
      endLatitude: branch.latitude,
      endLongitude: branch.longitude,
    );
  }

  /// Tentukan cabang terdekat berdasarkan koordinat pengguna
  StoreBranch getNearestBranch(double userLat, double userLng) {
    if (userLat == 0 && userLng == 0) return StoreBranch.sleman;
    final distSleman =
        calculateDistanceToBranch(StoreBranch.sleman, userLat, userLng);
    final distBantul =
        calculateDistanceToBranch(StoreBranch.bantul, userLat, userLng);
    return distSleman <= distBantul ? StoreBranch.sleman : StoreBranch.bantul;
  }

  /// Ganti cabang toko secara manual
  void setStoreBranch(StoreBranch branch, double subtotal) {
    autoSelectNearestStore.value = false;
    selectedStore.value = branch;
    try {
      if (Get.isRegistered<PrefService>()) {
        Get.find<PrefService>().setSelectedStoreId(branch.id);
      }
    } catch (_) {}
    if (selectedAddress.value != null) {
      updateDistanceAndShipping(selectedAddress.value!, subtotal);
    }
  }

  /// Aktifkan mode pilih otomatis toko terdekat
  void setAutoNearestStore(double subtotal) {
    autoSelectNearestStore.value = true;
    if (selectedAddress.value != null) {
      updateDistanceAndShipping(selectedAddress.value!, subtotal);
    }
  }

  void updateDistanceAndShipping(AddressModel address, double subtotal) {
    if (address.latitude == 0 && address.longitude == 0) {
      distanceKm.value = 0.0;
      distanceToSlemanKm.value = 0.0;
      distanceToBantulKm.value = 0.0;
      distanceLabel.value = '';
      currentShippingCost.value = LocationService.calculateShippingCost(
        distanceKm: null,
        subtotal: subtotal,
      );
      return;
    }

    // Hitung jarak ke masing-masing cabang toko (Sleman & Bantul)
    final distSleman = calculateDistanceToBranch(
        StoreBranch.sleman, address.latitude, address.longitude);
    final distBantul = calculateDistanceToBranch(
        StoreBranch.bantul, address.latitude, address.longitude);
    distanceToSlemanKm.value = distSleman;
    distanceToBantulKm.value = distBantul;

    // Jika mode otomatis aktif, pilih cabang dengan jarak terdekat
    if (autoSelectNearestStore.value) {
      selectedStore.value =
          distSleman <= distBantul ? StoreBranch.sleman : StoreBranch.bantul;
    }

    final activeStore = selectedStore.value;
    final activeDistance = activeStore.id == 'sleman' ? distSleman : distBantul;

    distanceKm.value = activeDistance;
    currentShippingCost.value = LocationService.calculateShippingCost(
      distanceKm: activeDistance,
      subtotal: subtotal,
    );
    distanceLabel.value =
        '${activeStore.city} (${activeDistance.toStringAsFixed(1)} km)';

    // Panggil Google Distance Matrix API untuk rute jalan nyata ke cabang terpilih
    _fetchGoogleDistanceAndShipping(address, subtotal, activeStore);
  }

  /// Ambil jarak & ongkir dari Google Distance Matrix API (async, non-blocking)
  Future<void> _fetchGoogleDistanceAndShipping(
      AddressModel address, double subtotal, StoreBranch store) async {
    try {
      final result = await MapService.calculateRoadDistance(
        originLat: address.latitude,
        originLng: address.longitude,
        destLat: store.latitude,
        destLng: store.longitude,
      );

      distanceResult.value = result;
      distanceKm.value = result.distanceKm;
      distanceLabel.value =
          '${store.city}: ${result.distanceText} (${result.durationText})';

      // Hitung ongkir berdasarkan jarak jalan nyata dari Google
      final shipping = await MapService.calculateShippingCostFromMaps(
        userLat: address.latitude,
        userLng: address.longitude,
        storeLat: store.latitude,
        storeLng: store.longitude,
        subtotal: subtotal,
      );
      currentShippingCost.value = shipping;
    } catch (_) {
      // Diam-diam tetap pakai Haversine jika Google API gagal
    }
  }

  /// Ambil hasil reverse geocoding dari Google untuk koordinat GPS
  Future<GeocodingResult?> fetchAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await MapService.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );
      geocodingResult.value = result;
      return result;
    } catch (_) {
      return null;
    }
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
