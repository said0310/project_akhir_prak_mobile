import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../widgets/glass_feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class OrderController extends GetxController {
  final OrderRepository orderRepository;

  OrderController({required this.orderRepository});

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString selectedPaymentMethod = 'Transfer Bank'.obs;
  final Rx<OrderModel?> currentOrder = Rx<OrderModel?>(null);

  final List<String> availablePaymentMethods = [
    'Transfer Bank',
    'E-Wallet (GoPay/OVO/ShopeePay)',
    'COD (Bayar di Tempat)',
  ];

  String get _currentUserId {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.id ?? 'user_1';
    }
    return 'user_1';
  }

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final list = await orderRepository.getOrders(_currentUserId);
      orders.assignAll(list);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  /// Buat Pesanan Baru (FR-CART-05, BR-06, BR-07, BR-08, BR-12, BR-13)
  Future<OrderModel?> placeOrder({
    required AddressModel address,
    required List<CartItemModel> selectedItems,
    required double shippingCost,
  }) async {
    if (selectedItems.isEmpty) {
      GlassFeedback.showSnackbar(
        title: 'Keranjang Kosong',
        message: 'Pilih minimal satu item untuk checkout.',
        isError: true,
      );
      return null;
    }

    try {
      isSubmitting.value = true;

      // 1. Panggil API POST /orders
      final createdOrder = await orderRepository.placeOrder(
        userId: _currentUserId,
        address: address,
        items: selectedItems,
        paymentMethod: selectedPaymentMethod.value,
        shippingCost: shippingCost,
      );

      // 2. Hapus HANYA item yang dibeli dari keranjang (BR-12, TC-14)
      if (Get.isRegistered<CartController>()) {
        final purchasedIds = selectedItems.map((i) => i.productId).toList();
        Get.find<CartController>().removePurchased(purchasedIds);
      }

      // 3. Tambahkan ke daftar orders lokal
      orders.insert(0, createdOrder);
      currentOrder.value = createdOrder;

      // 4. Picu Notifikasi Immediate (NT-04, TC-21)
      try {
        final notifId = createdOrder.id.hashCode & 0x7FFFFFFF;
        await NotificationService.showImmediateNotification(
          id: notifId,
          title: '🎉 Pesanan Berhasil Dibuat!',
          body: 'No. Pesanan: ${createdOrder.orderNumber} dengan total Rp ${createdOrder.total.toInt()}. Kami segera menyiapkan barang Anda.',
          payload: createdOrder.id,
        );
      } catch (notifErr) {
        debugPrint('Notifikasi dilewati jika izin belum aktif: $notifErr');
      }

      return createdOrder;
    } catch (e) {
      // Sesuai BR-13 & TC-15: Jika gagal, tampilkan pesan jelas, isi keranjang tetap utuh
      GlassFeedback.showSnackbar(
        title: 'Gagal Membuat Pesanan',
        message: e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', ''),
        isError: true,
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Lanjutkan status pesanan (Simulasi PATCH /orders/{id} untuk demo pengujian)
  Future<void> advanceStatus(String orderId) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final currentStatus = orders[index].status;
    String nextStatus = currentStatus;

    // Alur BR-08: Menunggu Pembayaran -> Diproses -> Dikemas -> Dikirim -> Selesai
    switch (currentStatus) {
      case 'Menunggu Pembayaran':
        nextStatus = 'Diproses';
        break;
      case 'Diproses':
        nextStatus = 'Dikemas';
        break;
      case 'Dikemas':
        nextStatus = 'Dikirim';
        break;
      case 'Dikirim':
        nextStatus = 'Selesai';
        break;
      default:
        return;
    }

    try {
      final updated = await orderRepository.updateStatus(orderId, nextStatus);
      orders[index] = updated;
      if (currentOrder.value?.id == orderId) {
        currentOrder.value = updated;
      }
      GlassFeedback.showSnackbar(
        title: 'Status Diperbarui',
        message: 'Status pesanan berubah menjadi: $nextStatus',
      );
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Memperbarui Status',
        message: e.toString(),
        isError: true,
      );
    }
  }

  /// Batalkan pesanan (Hanya dari Menunggu Pembayaran atau Diproses - BR-08)
  Future<void> cancelOrder(String orderId) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final currentStatus = orders[index].status;
    if (currentStatus != 'Menunggu Pembayaran' && currentStatus != 'Diproses') {
      GlassFeedback.showSnackbar(
        title: 'Tidak Dapat Dibatalkan',
        message: 'Pesanan yang sudah dalam proses pengiriman tidak dapat dibatalkan.',
        isError: true,
      );
      return;
    }

    try {
      final updated = await orderRepository.updateStatus(orderId, 'Dibatalkan');
      orders[index] = updated;
      if (currentOrder.value?.id == orderId) {
        currentOrder.value = updated;
      }
      GlassFeedback.showSnackbar(
        title: 'Pesanan Dibatalkan',
        message: 'Pesanan ${updated.orderNumber} telah dibatalkan.',
      );
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Membatalkan Pesanan',
        message: e.toString(),
        isError: true,
      );
    }
  }
}
