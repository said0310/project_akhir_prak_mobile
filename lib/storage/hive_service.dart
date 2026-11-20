import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../data/models/reminder_model.dart';
import '../data/models/address_model.dart';

// Type Adapters manual sesuai PRD Bagian 15
class CartItemAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 1;

  @override
  CartItemModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return CartItemModel.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class ProductAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 2;

  @override
  ProductModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return ProductModel.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class ReminderAdapter extends TypeAdapter<ReminderModel> {
  @override
  final int typeId = 3;

  @override
  ReminderModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return ReminderModel.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, ReminderModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class AddressAdapter extends TypeAdapter<AddressModel> {
  @override
  final int typeId = 4;

  @override
  AddressModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return AddressModel.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, AddressModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register TypeAdapters
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CartItemAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ProductAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ReminderAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(AddressAdapter());

    // Open Boxes
    await Hive.openBox<CartItemModel>(AppConstants.hiveCartBox);
    await Hive.openBox<ProductModel>(AppConstants.hiveWishlistBox);
    await Hive.openBox<ReminderModel>(AppConstants.hiveReminderBox);
    await Hive.openBox<AddressModel>(AppConstants.hiveAddressBox);
  }

  static Box<CartItemModel> get cartBox =>
      Hive.box<CartItemModel>(AppConstants.hiveCartBox);

  static Box<ProductModel> get wishlistBox =>
      Hive.box<ProductModel>(AppConstants.hiveWishlistBox);

  static Box<ReminderModel> get reminderBox =>
      Hive.box<ReminderModel>(AppConstants.hiveReminderBox);

  static Box<AddressModel> get addressBox =>
      Hive.box<AddressModel>(AppConstants.hiveAddressBox);
}
