import 'package:hive/hive.dart';
import '../models/address_model.dart';
import '../../storage/hive_service.dart';

class AddressRepository {
  Box<AddressModel> get _box => HiveService.addressBox;

  List<AddressModel> getAddresses(String userId) {
    final list = _box.values.where((a) {
      if (a.userId == userId) return true;
      if (a.userId.isEmpty || a.userId == 'guest' || a.userId == 'current') return true;
      if (userId.isEmpty || userId == 'guest' || userId == 'current') return true;
      return false;
    }).toList();

    return list;
  }

  AddressModel? getPrimaryAddress(String userId) {
    final list = getAddresses(userId);
    if (list.isEmpty) return null;
    try {
      return list.firstWhere((a) => a.isPrimary);
    } catch (_) {
      return list.first;
    }
  }

  Future<void> saveAddress(AddressModel address) async {
    // Jika dijadikan primary, hilangkan status primary dari alamat lama
    if (address.isPrimary) {
      final list = getAddresses(address.userId);
      for (var a in list) {
        if (a.id != address.id && a.isPrimary) {
          await _box.put(a.id, a.copyWith(isPrimary: false));
        }
      }
    }
    await _box.put(address.id, address);
  }

  Future<void> deleteAddress(String id) async {
    await _box.delete(id);
  }
}
