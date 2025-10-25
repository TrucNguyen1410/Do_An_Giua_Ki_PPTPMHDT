// lib/screens/admin_manage_activities.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import 'activity_form.dart'; // Import màn hình form
import 'activity_detail_screen.dart'; // <-- 1. IMPORT MÀN HÌNH CHI TIẾT

class AdminManageActivitiesScreen extends StatefulWidget {
  const AdminManageActivitiesScreen({Key? key}) : super(key: key);

  @override
  _AdminManageActivitiesScreenState createState() =>
      _AdminManageActivitiesScreenState();
}

class _AdminManageActivitiesScreenState
    extends State<AdminManageActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi hàm fetchActivitiesAdmin từ PROVIDER
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(context, listen: false)
          .fetchActivitiesAdmin();
    });
  }

  // Hàm xử lý xóa
  Future<void> _deleteActivity(String id) async {
    try {
      await Provider.of<ActivityProvider>(context, listen: false)
          .deleteActivity(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa hoạt động thành công')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Hoạt động'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Đi đến form để tạo mới
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityFormScreen(), // Chế độ tạo mới
                ),
              );
            },
          ),
        ],
      ),
      // Dùng Consumer để lắng nghe thay đổi từ Provider
      body: Consumer<ActivityProvider>(
        builder: (context, activityProvider, child) {
          if (activityProvider.isLoadingActivities) {
            return Center(child: CircularProgressIndicator());
          }

          if (activityProvider.activitiesError != null) {
            return Center(
                child: Text('Lỗi: ${activityProvider.activitiesError}'));
          }

          if (activityProvider.activities.isEmpty) {
            return Center(child: Text('Không có hoạt động nào.'));
          }

          return ListView.builder(
            itemCount: activityProvider.activities.length,
            itemBuilder: (context, index) {
              final activity = activityProvider.activities[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(activity.name),
                  subtitle: Text(activity.location),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút Sửa
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Đi đến form để sửa
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ActivityFormScreen(activity: activity), // Chế độ sửa
                            ),
                          );
                        },
                      ),
                      // Nút Xóa
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Hiển thị dialog xác nhận xóa
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Xác nhận xóa'),
                              content: Text(
                                  'Bạn có chắc muốn xóa hoạt động "${activity.name}"?'),
                              actions: [
                                TextButton(
                                  child: Text('Hủy'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                                TextButton(
                                  child: Text('Xóa',
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    _deleteActivity(activity.id);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  // <-- 2. THÊM SỰ KIỆN ONTAP VÀO ĐÂY
                  onTap: () {
                    // Mở màn hình chi tiết khi nhấn vào
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailScreen(
                          activity: activity, // Truyền hoạt động qua
                        ),
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