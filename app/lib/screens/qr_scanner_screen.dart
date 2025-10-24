// Cần import: package:mobile_scanner/mobile_scanner.dart';
// Cần import: activity_service.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// (Giả sử bạn đã có ActivityService)
// import '../services/activity_service.dart'; 

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã điểm danh')),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          if (_isProcessing) return;

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? token = barcodes.first.rawValue;
            if (token != null) {
              setState(() {
                _isProcessing = true;
              });
              controller.stop(); // Dừng camera
              _handleScan(token);
            }
          }
        },
      ),
    );
  }

  void _handleScan(String token) async {
    try {
      // Giả sử ActivityService có hàm submitAttendance
      // final activityService = Provider.of<ActivityService>(context, listen: false);
      // final message = await activityService.submitAttendance(token);
      
      // (Code giả định, bạn cần viết hàm này trong service)
      print('Đã quét được token: $token');
      // TODO: Gọi API POST /api/activities/attend với token này
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Điểm danh thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Quay về màn hình trước
    } catch (e) {
      // Xử lý lỗi (vd: token hết hạn, chưa đăng ký...)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
      );
      // Khởi động lại camera
      setState(() {
        _isProcessing = false;
        controller.start();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}