import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app.dart';
import '../models/models.dart';
import '../services/location_service.dart';
import '../services/map_service.dart';
import 'glass_feedback.dart';

/// ============================================================================
/// GoogleMapWidget — Widget Peta Interaktif & Ter-load Penuh (Wiji Bumi)
/// ============================================================================
/// Menggunakan tile server Google Maps Roadmap & OSM TileLayer yang 100%
/// ter-load tanpa blank abu-abu.
///
/// Fitur Skenario:
/// 1. Dua Cabang Toko Resmi Wiji Bumi:
///    • Cabang Sleman (-7.7600, 110.4080)
///    • Cabang Bantul (-7.8750, 110.3550)
/// 2. Pengukuran jarak akurat antara cabang toko dengan lokasi pembeli.
/// 3. Pemilihan lokasi fleksibel & presisi:
///    • Tombol GPS Akurat (My Location) dengan zoom level detail (16.5)
///    • Menggeser peta (Pan & Drag) dengan Center Pin ala Gojek/Grab
///    • Mengetuk layar (Tap-to-place) di titik manapun
/// 4. Garis rute pengiriman (Polyline) dari cabang toko terpilih ke pembeli.
/// 5. Pemilihan cabang toko (Sleman vs Bantul vs Terdekat Otomatis).
/// 6. Tampilan bersih: tanpa teks nama pribadi pada marker peta.
/// ============================================================================
class GoogleMapWidget extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;
  final String userMarkerTitle;
  final String userMarkerSnippet;
  final double height;
  final bool showStoreMarker;
  final bool showPolyline;
  final bool isPickerMode;
  final void Function(LatLng position)? onMapTap;
  final StoreBranch? selectedBranch;
  final void Function(StoreBranch branch)? onBranchChanged;

  const GoogleMapWidget({
    super.key,
    required this.userLatitude,
    required this.userLongitude,
    this.userMarkerTitle = 'Titik Pengiriman',
    this.userMarkerSnippet = 'Lokasi terpilih',
    this.height = 260,
    this.showStoreMarker = true,
    this.showPolyline = true,
    this.isPickerMode = true,
    this.onMapTap,
    this.selectedBranch,
    this.onBranchChanged,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late final MapController _mapController;
  late StoreBranch _activeBranch;
  bool _isMovingCamera = false;
  bool _isLocatingUser = false;
  LatLng? _currentCenterPos;

  // Koordinat Toko Resmi Wiji Bumi
  static final LatLng _slemanLatLng = LatLng(
    StoreBranch.sleman.latitude,
    StoreBranch.sleman.longitude,
  );
  static final LatLng _bantulLatLng = LatLng(
    StoreBranch.bantul.latitude,
    StoreBranch.bantul.longitude,
  );

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _activeBranch = widget.selectedBranch ?? _getNearestBranch();
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedBranch != null && widget.selectedBranch != _activeBranch) {
      _activeBranch = widget.selectedBranch!;
    }
    if ((oldWidget.userLatitude != widget.userLatitude ||
            oldWidget.userLongitude != widget.userLongitude) &&
        !_isMovingCamera) {
      if (widget.userLatitude != 0 && widget.userLongitude != 0) {
        _mapController.move(
          LatLng(widget.userLatitude, widget.userLongitude),
          _mapController.camera.zoom < 14.0 ? 15.5 : _mapController.camera.zoom,
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  StoreBranch _getNearestBranch() {
    if (widget.userLatitude == 0 && widget.userLongitude == 0) {
      return StoreBranch.sleman;
    }
    final distSleman = LocationService.calculateDistanceKm(
      startLatitude: widget.userLatitude,
      startLongitude: widget.userLongitude,
      endLatitude: _slemanLatLng.latitude,
      endLongitude: _slemanLatLng.longitude,
    );
    final distBantul = LocationService.calculateDistanceKm(
      startLatitude: widget.userLatitude,
      startLongitude: widget.userLongitude,
      endLatitude: _bantulLatLng.latitude,
      endLongitude: _bantulLatLng.longitude,
    );
    return distSleman <= distBantul ? StoreBranch.sleman : StoreBranch.bantul;
  }

  LatLng get _targetPosition {
    if (widget.userLatitude != 0 || widget.userLongitude != 0) {
      return LatLng(widget.userLatitude, widget.userLongitude);
    }
    // Default fokus ke area Sleman / Yogyakarta
    return const LatLng(-7.7600, 110.4080);
  }

  LatLng get _activeStoreLatLng {
    return _activeBranch.id == 'bantul' ? _bantulLatLng : _slemanLatLng;
  }

  double _getDistanceToBranch(StoreBranch branch) {
    final userLat = widget.isPickerMode && _currentCenterPos != null
        ? _currentCenterPos!.latitude
        : widget.userLatitude;
    final userLng = widget.isPickerMode && _currentCenterPos != null
        ? _currentCenterPos!.longitude
        : widget.userLongitude;

    if (userLat == 0 && userLng == 0) return 0.0;
    return LocationService.calculateDistanceKm(
      startLatitude: userLat,
      startLongitude: userLng,
      endLatitude: branch.latitude,
      endLongitude: branch.longitude,
    );
  }

  void _switchBranch(StoreBranch branch) {
    setState(() {
      _activeBranch = branch;
    });
    widget.onBranchChanged?.call(branch);
  }

  /// Pindahkan kamera ke koordinat GPS fisik HP pengguna dengan akurasi tinggi
  Future<void> _moveToCurrentGps() async {
    setState(() {
      _isLocatingUser = true;
    });
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null && mounted) {
        final newPoint = LatLng(pos.latitude, pos.longitude);
        _currentCenterPos = newPoint;
        // Zoom mendalam ke level jalan / rumah agar sangat akurat
        _mapController.move(newPoint, 16.5);
        widget.onMapTap?.call(newPoint);
        GlassFeedback.showSnackbar(
          title: 'Lokasi Akurat Ditemukan',
          message: 'GPS terarah: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
        );
      } else if (mounted) {
        GlassFeedback.showSnackbar(
          title: 'Gagal Membaca GPS',
          message: 'Pastikan izin dan layanan lokasi (GPS) pada perangkat aktif.',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        GlassFeedback.showSnackbar(
          title: 'Gagal Membaca Lokasi',
          message: e.toString(),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocatingUser = false;
        });
      }
    }
  }

  void _showApiKeyDialog() {
    final textController = TextEditingController(text: MapService.apiKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WijiBumiColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: WijiBumiColors.freshLeaf, size: 22),
            SizedBox(width: 8),
            Text(
              'Pengaturan Google API Key',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Google Maps Platform API Key (Geocoding & Distance Matrix API) Anda:',
              style: TextStyle(color: WijiBumiColors.textMutedLight, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: WijiBumiColors.freshLeaf),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '💡 Tips Praktikum: Peta Wiji Bumi memuat ubin Google Maps Roadmap secara online dan menghitung rute LBS ke Sleman & Bantul. API Key digunakan untuk Geocoding & Distance Matrix API resmi.',
              style: TextStyle(color: WijiBumiColors.softSage, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WijiBumiColors.freshLeaf,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await MapService.setApiKey(textController.text);
              Navigator.pop(ctx);
              setState(() {});
              GlassFeedback.showSnackbar(
                title: 'API Key Diperbarui',
                message: textController.text.trim().isEmpty
                    ? 'API Key dikosongkan. Mode LBS Cerdas aktif.'
                    : 'API Key Google Maps berhasil disimpan.',
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  /// Buka Tampilan Pemilih Lokasi Layar Penuh (Fullscreen Map Picker)
  void _openFullscreenPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _FullscreenMapPickerView(
          initialLatitude: widget.userLatitude != 0 ? widget.userLatitude : -7.7600,
          initialLongitude: widget.userLongitude != 0 ? widget.userLongitude : 110.4080,
          activeBranch: _activeBranch,
          onLocationSelected: (pos) {
            widget.onMapTap?.call(pos);
            _mapController.move(pos, 16.0);
          },
        ),
      ),
    );
  }

  /// Buka Google Maps aplikasi eksternal / web browser
  void _openExternalGoogleMaps() async {
    final userLat = widget.userLatitude != 0 ? widget.userLatitude : _targetPosition.latitude;
    final userLng = widget.userLongitude != 0 ? widget.userLongitude : _targetPosition.longitude;
    final storeLat = _activeStoreLatLng.latitude;
    final storeLng = _activeStoreLatLng.longitude;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$storeLat,$storeLng&destination=$userLat,$userLng&travelmode=driving',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        GlassFeedback.showSnackbar(
          title: 'Gagal Membuka Maps',
          message: 'Tidak dapat membuka aplikasi Google Maps.',
          isError: true,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final distSleman = _getDistanceToBranch(StoreBranch.sleman);
    final distBantul = _getDistanceToBranch(StoreBranch.bantul);
    final activeDist = _activeBranch.id == 'bantul' ? distBantul : distSleman;

    final userLat = widget.isPickerMode && _currentCenterPos != null
        ? _currentCenterPos!.latitude
        : widget.userLatitude;
    final userLng = widget.isPickerMode && _currentCenterPos != null
        ? _currentCenterPos!.longitude
        : widget.userLongitude;
    final hasUserPos = userLat != 0 && userLng != 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2620),
          border: Border.all(color: WijiBumiColors.freshLeaf.withOpacity(0.6), width: 1.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ================================================================
            // 1. ENGINE PETA FLUTTER MAP DENGAN TILE GOOGLE MAPS ROADMAP
            // ================================================================
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _targetPosition,
                initialZoom: widget.userLatitude != 0 ? 15.5 : 13.5,
                minZoom: 4.0,
                maxZoom: 19.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPosition, point) {
                  _currentCenterPos = point;
                  widget.onMapTap?.call(point);
                  _mapController.move(point, _mapController.camera.zoom);
                },
                onPositionChanged: (camera, hasGesture) {
                  _currentCenterPos = camera.center;
                  if (hasGesture && !_isMovingCamera) {
                    setState(() {
                      _isMovingCamera = true;
                    });
                  }
                },
                onMapEvent: (event) {
                  if (event is MapEventMoveEnd) {
                    final currentCenter = _mapController.camera.center;
                    _currentCenterPos = currentCenter;
                    setState(() {
                      _isMovingCamera = false;
                    });
                    if (widget.isPickerMode) {
                      widget.onMapTap?.call(currentCenter);
                    }
                  }
                },
              ),
              children: [
                // Layer Tile Peta Google Maps Roadmap (dan fallback OpenStreetMap)
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.wijibumi.app',
                  maxZoom: 19,
                ),

                // Garis Rute Pengiriman (Polyline) antara Toko Terpilih ke Pembeli
                if (widget.showPolyline && hasUserPos)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          _activeStoreLatLng,
                          LatLng(userLat, userLng),
                        ],
                        strokeWidth: 4.0,
                        color: WijiBumiColors.deepForest,
                        borderStrokeWidth: 1.5,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),

                // Marker Cabang Toko & Marker Pembeli
                MarkerLayer(
                  markers: [
                    // Marker Cabang Sleman
                    if (widget.showStoreMarker)
                      Marker(
                        point: _slemanLatLng,
                        width: 90,
                        height: 55,
                        child: GestureDetector(
                          onTap: () => _switchBranch(StoreBranch.sleman),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _activeBranch.id == 'sleman'
                                      ? WijiBumiColors.deepForest
                                      : Colors.black87,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _activeBranch.id == 'sleman'
                                        ? WijiBumiColors.freshLeaf
                                        : Colors.white54,
                                    width: 1.2,
                                  ),
                                ),
                                child: const Text(
                                  '🌿 Toko Sleman',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.store_mall_directory_rounded,
                                color: Color(0xFF2E7D32),
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Marker Cabang Bantul
                    if (widget.showStoreMarker)
                      Marker(
                        point: _bantulLatLng,
                        width: 90,
                        height: 55,
                        child: GestureDetector(
                          onTap: () => _switchBranch(StoreBranch.bantul),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _activeBranch.id == 'bantul'
                                      ? WijiBumiColors.deepForest
                                      : Colors.black87,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _activeBranch.id == 'bantul'
                                        ? WijiBumiColors.freshLeaf
                                        : Colors.white54,
                                    width: 1.2,
                                  ),
                                ),
                                child: const Text(
                                  '🌿 Toko Bantul',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.store_mall_directory_rounded,
                                color: Color(0xFF2E7D32),
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Marker User (HANYA PIN MERAH BERSIH, TANPA NAMA PRIBADI)
                    if (!widget.isPickerMode && hasUserPos)
                      Marker(
                        point: LatLng(userLat, userLng),
                        width: 44,
                        height: 48,
                        child: const Center(
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Colors.redAccent,
                            size: 38,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // ================================================================
            // 2. CENTER PIN BERGERAK (Mode Picker ala Gojek/Grab)
            // ================================================================
            if (widget.isPickerMode)
              IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  transform: Matrix4.translationValues(0, _isMovingCamera ? -14 : 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: WijiBumiColors.deepForest.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white30, width: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _isMovingCamera ? 'Lepas untuk memilih...' : 'Titik Pengiriman',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.location_pin,
                        color: Colors.redAccent,
                        size: 38,
                      ),
                      Container(
                        width: 10,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ================================================================
            // 3. HEADER OVERLAY: PILIH CABANG TOKO & TOMBOL AKSI
            // ================================================================
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Badge Pilihan Cabang Toko Sleman / Bantul
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBranchPill(
                            branch: StoreBranch.sleman,
                            isSelected: _activeBranch.id == 'sleman',
                            distanceKm: distSleman,
                          ),
                          const SizedBox(width: 5),
                          _buildBranchPill(
                            branch: StoreBranch.bantul,
                            isSelected: _activeBranch.id == 'bantul',
                            distanceKm: distBantul,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Tombol Layar Penuh dan Pengaturan Key
                  _buildMiniButton(
                    icon: Icons.fullscreen_rounded,
                    onTap: _openFullscreenPicker,
                  ),
                  const SizedBox(width: 4),
                  _buildMiniButton(
                    icon: Icons.vpn_key_rounded,
                    iconColor: Colors.amber,
                    onTap: _showApiKeyDialog,
                  ),
                ],
              ),
            ),

            // ================================================================
            // 4. FOOTER OVERLAY: INFO JARAK KE TOKO TERPILIH
            // ================================================================
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: WijiBumiColors.surfaceDark.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: WijiBumiColors.freshLeaf.withOpacity(0.6), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.navigation_rounded, color: WijiBumiColors.freshLeaf, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hasUserPos
                                  ? 'Dikirim dari: ${_activeBranch.name} (${activeDist.toStringAsFixed(1)} km)'
                                  : 'Geser layar atau gunakan tombol GPS untuk memilih lokasi',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _openExternalGoogleMaps,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_outlined, color: Colors.lightBlueAccent, size: 11),
                            SizedBox(width: 2),
                            Text('Rute', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================================================================
            // 5. TOMBOL KONTROL ZOOM & GPS SAYA DI SISI KANAN
            // ================================================================
            Positioned(
              right: 8,
              bottom: 46,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Akurat: Melompat ke Lokasi GPS HP Saya
                  _buildMiniButton(
                    icon: _isLocatingUser ? Icons.hourglass_empty_rounded : Icons.my_location_rounded,
                    iconColor: WijiBumiColors.freshLeaf,
                    onTap: _isLocatingUser ? () {} : _moveToCurrentGps,
                  ),
                  const SizedBox(height: 5),
                  _buildMiniButton(
                    icon: Icons.add,
                    onTap: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildMiniButton(
                    icon: Icons.remove,
                    onTap: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  // Tombol Fokus ke Toko Sleman/Bantul
                  _buildMiniButton(
                    icon: Icons.store_outlined,
                    onTap: () {
                      _mapController.move(_activeStoreLatLng, 14.5);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchPill({
    required StoreBranch branch,
    required bool isSelected,
    required double distanceKm,
  }) {
    return GestureDetector(
      onTap: () => _switchBranch(branch),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? WijiBumiColors.freshLeaf
              : WijiBumiColors.surfaceDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_rounded,
              size: 12,
              color: isSelected ? Colors.white : WijiBumiColors.freshLeaf,
            ),
            const SizedBox(width: 4),
            Text(
              '${branch.city} ${distanceKm > 0 ? "(${distanceKm.toStringAsFixed(1)}km)" : ""}',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: WijiBumiColors.surfaceDark.withOpacity(0.92),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 18),
      ),
    );
  }
}

/// ============================================================================
/// Halaman Penuh Pemilih Lokasi (Fullscreen Map Picker Modal)
/// Pengalaman layaknya aplikasi Gojek/Grab untuk menggeser peta dengan leluasa
/// ============================================================================
class _FullscreenMapPickerView extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final StoreBranch activeBranch;
  final ValueChanged<LatLng> onLocationSelected;

  const _FullscreenMapPickerView({
    required this.initialLatitude,
    required this.initialLongitude,
    required this.activeBranch,
    required this.onLocationSelected,
  });

  @override
  State<_FullscreenMapPickerView> createState() => _FullscreenMapPickerViewState();
}

class _FullscreenMapPickerViewState extends State<_FullscreenMapPickerView> {
  late final MapController _mapController;
  late LatLng _currentLocation;
  late StoreBranch _selectedBranch;
  bool _isMoving = false;
  bool _isLocatingGps = false;
  String _detectedStreet = 'Memuat lokasi...';
  String _detectedDistrict = '';
  bool _isLoadingAddress = false;

  static final LatLng _slemanLatLng = LatLng(
    StoreBranch.sleman.latitude,
    StoreBranch.sleman.longitude,
  );
  static final LatLng _bantulLatLng = LatLng(
    StoreBranch.bantul.latitude,
    StoreBranch.bantul.longitude,
  );

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLocation = LatLng(widget.initialLatitude, widget.initialLongitude);
    _selectedBranch = widget.activeBranch;
    _resolveAddress(_currentLocation);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _resolveAddress(LatLng pos) async {
    setState(() {
      _isLoadingAddress = true;
    });
    final res = await MapService.reverseGeocode(
      latitude: pos.latitude,
      longitude: pos.longitude,
    );
    if (mounted) {
      setState(() {
        _isLoadingAddress = false;
        _detectedStreet = res.streetName;
        _detectedDistrict = '${res.sublocality}, ${res.city}';
      });
    }
  }

  Future<void> _locateGps() async {
    setState(() {
      _isLocatingGps = true;
    });
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null && mounted) {
        final point = LatLng(pos.latitude, pos.longitude);
        _currentLocation = point;
        _mapController.move(point, 16.5);
        _resolveAddress(point);
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isLocatingGps = false;
        });
      }
    }
  }

  double _getDistanceTo(StoreBranch branch) {
    return LocationService.calculateDistanceKm(
      startLatitude: _currentLocation.latitude,
      startLongitude: _currentLocation.longitude,
      endLatitude: branch.latitude,
      endLongitude: branch.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final distSleman = _getDistanceTo(StoreBranch.sleman);
    final distBantul = _getDistanceTo(StoreBranch.bantul);
    final activeDist = _selectedBranch.id == 'bantul' ? distBantul : distSleman;

    return Scaffold(
      backgroundColor: WijiBumiColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Geser & Tentukan Titik Lokasi'),
        backgroundColor: WijiBumiColors.surfaceDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isLocatingGps
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.my_location_rounded, color: WijiBumiColors.freshLeaf),
            tooltip: 'Ke Posisi GPS Saya',
            onPressed: _isLocatingGps ? null : _locateGps,
          ),
        ],
      ),
      body: Stack(
        children: [
          // FlutterMap Fullscreen
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.5,
              minZoom: 4.0,
              maxZoom: 19.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, point) {
                _currentLocation = point;
                _mapController.move(point, _mapController.camera.zoom);
                _resolveAddress(point);
              },
              onPositionChanged: (camera, hasGesture) {
                _currentLocation = camera.center;
                if (hasGesture && !_isMoving) {
                  setState(() {
                    _isMoving = true;
                  });
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _currentLocation = _mapController.camera.center;
                  setState(() {
                    _isMoving = false;
                  });
                  _resolveAddress(_currentLocation);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.wijibumi.app',
                maxZoom: 19,
              ),

              // Rute garis ke toko terpilih
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      _selectedBranch.id == 'bantul' ? _bantulLatLng : _slemanLatLng,
                      _currentLocation,
                    ],
                    strokeWidth: 4.0,
                    color: WijiBumiColors.deepForest,
                    borderStrokeWidth: 1.5,
                    borderColor: Colors.white,
                  ),
                ],
              ),

              // Marker Toko Sleman & Bantul
              MarkerLayer(
                markers: [
                  Marker(
                    point: _slemanLatLng,
                    width: 100,
                    height: 55,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBranch = StoreBranch.sleman;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _selectedBranch.id == 'sleman'
                                  ? WijiBumiColors.deepForest
                                  : Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: const Text(
                              '🌿 Sleman',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(Icons.store_mall_directory_rounded, color: Color(0xFF2E7D32), size: 30),
                        ],
                      ),
                    ),
                  ),
                  Marker(
                    point: _bantulLatLng,
                    width: 100,
                    height: 55,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBranch = StoreBranch.bantul;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _selectedBranch.id == 'bantul'
                                  ? WijiBumiColors.deepForest
                                  : Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: const Text(
                              '🌿 Bantul',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(Icons.store_mall_directory_rounded, color: Color(0xFF2E7D32), size: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center Pin Penunjuk Lokasi
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              transform: Matrix4.translationValues(0, _isMoving ? -18 : 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_pin, color: Colors.redAccent, size: 48),
                  Container(
                    width: 12,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selector Toko Mengapung di Atas
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBranchChip(
                  branch: StoreBranch.sleman,
                  isSelected: _selectedBranch.id == 'sleman',
                  distanceKm: distSleman,
                ),
                const SizedBox(width: 8),
                _buildBranchChip(
                  branch: StoreBranch.bantul,
                  isSelected: _selectedBranch.id == 'bantul',
                  distanceKm: distBantul,
                ),
              ],
            ),
          ),

          // Tombol Zoom & GPS di Kanan Layar
          Positioned(
            right: 16,
            bottom: 210,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'fs_my_location',
                  backgroundColor: WijiBumiColors.surfaceDark,
                  foregroundColor: WijiBumiColors.freshLeaf,
                  onPressed: _locateGps,
                  child: const Icon(Icons.my_location_rounded),
                ),
                const SizedBox(height: 6),
                FloatingActionButton.small(
                  heroTag: 'fs_zoom_in',
                  backgroundColor: WijiBumiColors.surfaceDark,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 6),
                FloatingActionButton.small(
                  heroTag: 'fs_zoom_out',
                  backgroundColor: WijiBumiColors.surfaceDark,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // Banner Informasi Lokasi & Tombol Konfirmasi di Bawah
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WijiBumiColors.surfaceDark.withOpacity(0.96),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WijiBumiColors.freshLeaf, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, color: WijiBumiColors.freshLeaf, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isLoadingAddress
                              ? 'Mencari alamat via Geocoding...'
                              : _detectedStreet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_detectedDistrict.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: Text(
                        _detectedDistrict,
                        style: const TextStyle(color: WijiBumiColors.textMutedLight, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      'Jarak ke ${_selectedBranch.name}: ${activeDist.toStringAsFixed(1)} km',
                      style: const TextStyle(color: WijiBumiColors.freshLeaf, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      'Koordinat: ${_currentLocation.latitude.toStringAsFixed(5)}, ${_currentLocation.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WijiBumiColors.freshLeaf,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text('Gunakan Titik Lokasi Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        widget.onLocationSelected(_currentLocation);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchChip({
    required StoreBranch branch,
    required bool isSelected,
    required double distanceKm,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBranch = branch;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? WijiBumiColors.freshLeaf : WijiBumiColors.surfaceDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 1.5 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_rounded, size: 14, color: isSelected ? Colors.white : WijiBumiColors.freshLeaf),
            const SizedBox(width: 4),
            Text(
              '${branch.name} (${distanceKm.toStringAsFixed(1)} km)',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
