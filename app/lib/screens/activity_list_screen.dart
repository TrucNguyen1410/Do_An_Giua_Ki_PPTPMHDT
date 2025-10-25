// lib/screens/activity_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import 'activity_detail_screen.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({Key? key}) : super(key: key);

  @override
  _ActivityListScreenState createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi hàm fetchActivities ngay khi màn hình được tải
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(context, listen: false).fetchActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Hoạt động'),
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingActivities) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.activitiesError != null) {
            return Center(
              child: Text('Lỗi tải dữ liệu: ${provider.activitiesError}'),
            );
          }

          if (provider.activities.isEmpty) {
            return const Center(child: Text('Không có hoạt động nào.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.activities.length,
            itemBuilder: (context, index) {
              final activity = provider.activities[index];
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
                    '${activity.location}\n${activity.date.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: Text(
                    activity.isRegistered ? "Đã ĐK" : "Chưa ĐK",
                    style: TextStyle(
                      color: activity.isRegistered ? Colors.green : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
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