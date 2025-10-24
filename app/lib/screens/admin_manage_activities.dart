// lib/screens/admin_manage_activities.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import 'activity_form.dart'; // Import màn hình form

class AdminManageActivitiesScreen extends StatefulWidget {
  const AdminManageActivitiesScreen({super.key});

  @override
  _AdminManageActivitiesScreenState createState() =>
      _AdminManageActivitiesScreenState();
}

class _AdminManageActivitiesScreenState
    extends State<AdminManageActivitiesScreen> {
  late Future<void> _fetchActivitiesFuture;

  @override
  void initState() {
    super.initState();
    // Gọi hàm fetchActivitiesAdmin khi màn hình được tải
    _fetchActivitiesFuture = Provider.of<ActivityService>(context, listen: false)
        .fetchActivitiesAdmin();
  }

  // Hàm để điều hướng đến form
  void _navigateToForm({Activity? activity}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityFormScreen(activity: activity),
      ),
    ).then((_) {
      // Sau khi quay lại từ form, làm mới danh sách
      // (Cách đơn giản nhất là fetch lại)
      setState(() {
        _fetchActivitiesFuture = Provider.of<ActivityService>(context, listen: false)
            .fetchActivitiesAdmin();
      });
    });
  }

  // Hàm xử lý xóa
  Future<void> _deleteActivity(BuildContext context, String id) async {
    try {
      await Provider.of<ActivityService>(context, listen: false)
          .deleteActivity(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa hoạt động thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Hoạt động'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Đi đến form để "Tạo mới" (không truyền activity)
              _navigateToForm();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchActivitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
            );
          }

          // Nếu thành công, dùng Consumer để lấy data
          return Consumer<ActivityService>(
            builder: (context, activityService, child) {
              if (activityService.activities.isEmpty) {
                return const Center(
                  child: Text('Chưa có hoạt động nào. Bấm + để thêm.'),
                );
              }

              // Hiển thị danh sách
              return ListView.builder(
                itemCount: activityService.activities.length,
                itemBuilder: (context, index) {
                  final activity = activityService.activities[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(activity.title),
                      subtitle: Text(
                          '${activity.location} - ${activity.date.day}/${activity.date.month}/${activity.date.year}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nút Sửa
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Đi đến form để "Sửa" (truyền activity)
                              _navigateToForm(activity: activity);
                            },
                          ),
                          // Nút Xóa
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Hiển thị dialog xác nhận xóa
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: Text(
                                      'Bạn có chắc muốn xóa hoạt động "${activity.title}"?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Hủy'),
                                      onPressed: () => Navigator.of(ctx).pop(),
                                    ),
                                    TextButton(
                                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        _deleteActivity(context, activity.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}