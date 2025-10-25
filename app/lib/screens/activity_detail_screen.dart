// lib/screens/activity_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; // <-- 1. IMPORT THƯ VIỆN QR
import '../models/activity.dart';
import '../providers/activity_provider.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;

  const ActivityDetailScreen({Key? key, required this.activity}) : super(key: key);

  // 2. HÀM HIỂN THỊ POP-UP QR CODE
  void _showQrDialog(BuildContext context, String activityId, String activityName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('QR Điểm danh: $activityName'),
          content: Container(
            // Đặt kích thước cố định để Dialog không bị vỡ
            width: 300,
            height: 300,
            child: QrImageView(
              data: activityId, // <-- Dữ liệu của QR chính là ID của hoạt động
              version: QrVersions.auto,
              size: 300.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dùng Consumer để lắng nghe thay đổi
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        // Tìm trạng thái mới nhất của activity này từ provider
        final liveActivity = provider.activities.firstWhere(
          (a) => a.id == activity.id,
          orElse: () => activity, // Nếu không tìm thấy, dùng object cũ
        );
        
        bool isRegistered = liveActivity.isRegistered;
        bool isLoading = provider.isActivityLoading(liveActivity.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(liveActivity.name),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  liveActivity.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: 'Ngày: ${liveActivity.date.toLocal().toString().split(' ')[0]}',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: 'Địa điểm: ${liveActivity.location}',
                ),
                const SizedBox(height: 24),
                Text(
                  'Mô tả hoạt động:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      liveActivity.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 3. NÚT HIỆN QR CHO ADMIN (ĐÃ THÊM)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.qr_code_2_sharp),
                    label: Text(
                      'HIỆN QR ĐIỂM DANH',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _showQrDialog(context, liveActivity.id, liveActivity.name);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, // Màu chính
                      foregroundColor: Colors.white, // Chữ trắng
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12), // Khoảng cách giữa 2 nút

                // Nút Đăng ký / Hủy (của Sinh viên)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null // Vô hiệu hóa nút khi đang loading
                        : () {
                            provider.toggleRegistration(liveActivity);
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        : Text(
                            isRegistered ? 'HỦY ĐĂNG KÝ' : 'ĐĂNG KÝ',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRegistered ? Colors.red.shade600 : Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget phụ trợ cho đẹp (Nằm bên ngoài class ActivityDetailScreen)
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({Key? key, required this.icon, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 20),
        const SizedBox(width: 12),
        Text(text, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

