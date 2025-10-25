// lib/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false; // Cờ để tránh quét nhiều lần

  @override
  void dispose() {
    controller.dispose(); // Hủy controller khi màn hình bị đóng
    super.dispose();
  }

  // Hàm xử lý logic điểm danh
  Future<void> _handleAttendance(String activityId) async {
    if (_isProcessing) return; // Nếu đang xử lý, không làm gì cả

    setState(() {
      _isProcessing = true; // Báo là đang xử lý
    });

    try {
      // 1. Gọi Provider để điểm danh
      await Provider.of<ActivityProvider>(context, listen: false)
          .markAttendance(activityId);

      // 2. Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Điểm danh thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // 3. Tự động quay lại màn hình trước
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // 4. Thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      // 5. Cho phép quét lại nếu lỗi
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quét mã QR điểm danh'),
        actions: [
          // Nút bật/tắt đèn flash (ĐÃ ĐƠN GIẢN HÓA)
          IconButton(
            icon: Icon(Icons.flash_on),
            color: Colors.white,
            onPressed: () => controller.toggleTorch(),
          ),
          // Nút chuyển camera
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: controller,
            // Hàm được gọi khi phát hiện mã QR
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? activityId = barcodes.first.rawValue;
                if (activityId != null && activityId.isNotEmpty && !_isProcessing) {
                  // Dừng camera và xử lý điểm danh
                  _handleAttendance(activityId);
                }
              }
            },
          ),

          // Lớp phủ (overlay) mờ với 1 ô vuông ở giữa
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red.shade400,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Hiển thị vòng xoay loading khi đang xử lý
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}