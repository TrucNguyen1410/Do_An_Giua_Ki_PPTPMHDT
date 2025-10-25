// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import 'activity_detail_screen.dart'; // Để có thể xem lại chi tiết

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi hàm fetchHistory ngay khi màn hình được tải
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(context, listen: false).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử Đăng ký'),
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHistory) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.historyError != null) {
            return Center(
              child: Text('Lỗi tải dữ liệu: ${provider.historyError}'),
            );
          }

          if (provider.history.isEmpty) {
            return const Center(child: Text('Bạn chưa đăng ký hoạt động nào.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final activity = provider.history[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  title: Text(
                    activity.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Đã đăng ký - Ngày: ${activity.date.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () {
                    // Cho phép xem lại chi tiết
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailScreen(activity: activity),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}