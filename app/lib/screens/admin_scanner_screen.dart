// lib/screens/admin_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import gói QR
import '../services/api_client.dart'; // Import ApiClient để gọi API

class AdminScannerScreen extends StatefulWidget {
  final String activityId;
  final String activityTitle;

  const AdminScannerScreen({
    Key? key,
    required this.activityId,
    required this.activityTitle,
  }) : super(key: key);

  @override
  _AdminScannerScreenState createState() => _AdminScannerScreenState();
}

class _AdminScannerScreenState extends State<AdminScannerScreen> {
  String? _attendanceToken;
  bool _isLoading = true;
  String? _errorMessage;

  // Sử dụng ApiClient để gọi API
  // Bạn không cần Provider ở đây vì đây là một hành động (action)
  // không phải là quản lý một state toàn cục
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    // Tải token lần đầu tiên khi màn hình được mở
    _generateQrToken();
  }

  // Hàm gọi API để lấy token
  Future<void> _generateQrToken() async {
    // Đặt lại trạng thái
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _attendanceToken = null; // Xóa token cũ
    });

    try {
      // Gọi API mà chúng ta đã tạo bên backend (api/routes/admin.js)
      // POST api/admin/activities/:id/generate-qr
      final response = await _apiClient.post(
        'admin/activities/${widget.activityId}/generate-qr',
        {}, // Không cần body
      );

      if (response['attendanceToken'] == null) {
        throw Exception('Không nhận được token từ server.');
      }

      // Lưu token và cập nhật UI
      setState(() {
        _attendanceToken = response['attendanceToken'];
        _isLoading = false;
      });
    } catch (e) {
      // Báo lỗi
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo mã QR Điểm danh'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.activityTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Vùng hiển thị QR Code
              Container(
                width: 250,
                height: 250,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildQrContent(),
              ),
              const SizedBox(height: 24),
              
              // Hiển thị thông báo (quan trọng)
              Text(
                _isLoading 
                  ? 'Đang tạo mã...' 
                  : (_attendanceToken != null 
                      ? 'Mã QR có hiệu lực trong 5 phút.' // Thông báo từ backend
                      : 'Không thể tạo mã.'),
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: _errorMessage != null 
                    ? Theme.of(context).colorScheme.error 
                    : Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Hiển thị chi tiết lỗi nếu có
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),

              // Nút "Tạo lại mã mới"
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Tạo lại mã mới'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _generateQrToken, // Vô hiệu hóa khi đang tải
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget con để hiển thị nội dung bên trong khung QR
  Widget _buildQrContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 80,
          ),
        ),
      );
    }

    if (_attendanceToken != null) {
      // Hiển thị mã QR
      return Padding(
        padding: const EdgeInsets.all(12.0), // Tạo khoảng đệm cho mã QR
        child: QrImageView(
          data: _attendanceToken!,
          version: QrVersions.auto,
          size: 220.0, // Kích thước QR bên trong container 250
        ),
      );
    }

    // Trường hợp không mong muốn
    return const Center(child: Text('Đã xảy ra lỗi không xác định.'));
  }
}