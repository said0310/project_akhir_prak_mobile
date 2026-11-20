class AppConstants {
  static const String appName = 'Wiji Bumi';
  static const String appTagline = 'Segar, Alami, dan Ramah Lingkungan';

  // SharedPreferences Keys
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserId = 'user_id';
  static const String prefSessionToken = 'session_token';
  static const String prefThemeMode = 'theme_mode';
  static const String prefNotifEnabled = 'notif_enabled';

  // Hive Boxes
  static const String hiveCartBox = 'cartBox';
  static const String hiveWishlistBox = 'wishlistBox';
  static const String hiveReminderBox = 'reminderBox';
  static const String hiveAddressBox = 'addressBox';

  // Notification Channel
  static const String notifChannelId = 'wiji_bumi_channel';
  static const String notifChannelName = 'Notifikasi Wiji Bumi';
  static const String notifChannelDescription = 'Notifikasi pesanan dan pengingat belanja Wiji Bumi';

  // Toko / Kebun Pusat (Pusat Koordinat Seller Default)
  static const double storeLatitude = -6.2088;
  static const double storeLongitude = 106.8456;
  static const String storeName = 'Kebun Pusat Wiji Bumi';
  static const String storeLocationName = 'Jakarta Selatan';

  // Ongkir Rules (BR-06)
  static const double baseDistanceKm = 5.0;
  static const double baseShippingCost = 5000.0;
  static const double perKmShippingCost = 1500.0;
  static const double maxShippingCost = 25000.0;
  static const double flatShippingCost = 10000.0;
  static const double freeShippingThreshold = 200000.0;
}
