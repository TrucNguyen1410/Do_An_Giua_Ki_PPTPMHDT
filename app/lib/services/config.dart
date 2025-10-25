// lib/services/config.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class Config {
  static String? _cachedBaseUrl;

  // IP của máy tính bạn (thay bằng IP thực của bạn)
  static const String _localIp = '10.221.106.16'; // <-- THAY ĐỔI CHỖ NÀY
  static const String _port = '4000';

  // URL cho emulator
  static const String _emulatorUrl = 'http://10.0.2.2:$_port/api';

  // URL cho thiết bị thật
  static const String _realDeviceUrl = 'http://$_localIp:$_port/api';

  /// Lấy base URL tự động
  static Future<String> getBaseUrl() async {
    // Nếu đã cache, trả về luôn
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }

    // Chỉ kiểm tra trên Android
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        // Kiểm tra xem có phải emulator không
        final isEmulator = !androidInfo.isPhysicalDevice;

        _cachedBaseUrl = isEmulator ? _emulatorUrl : _realDeviceUrl;

        print('🔧 Môi trường: ${isEmulator ? "EMULATOR" : "THIẾT BỊ THẬT"}');
        print('🌐 API URL: $_cachedBaseUrl');

        return _cachedBaseUrl!;
      } catch (e) {
        print('⚠️ Lỗi phát hiện thiết bị: $e');
        // Mặc định dùng emulator URL nếu lỗi
        _cachedBaseUrl = _emulatorUrl;
        return _cachedBaseUrl!;
      }
    }

    // Các nền tảng khác (iOS, Desktop) dùng local IP
    _cachedBaseUrl = _realDeviceUrl;
    return _cachedBaseUrl!;
  }

  /// Reset cache (dùng khi cần kiểm tra lại)
  static void resetCache() {
    _cachedBaseUrl = null;
  }
}
