// lib/screens/attendance_activity_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import 'attendance_detail_screen.dart'; // Import màn hình chi tiết điểm danh

class AttendanceActivityListScreen extends StatefulWidget {
  const AttendanceActivityListScreen({Key? key}) : super(key: key);

  @override
  _AttendanceActivityListScreenState createState() =>
      _AttendanceActivityListScreenState();
}

class _AttendanceActivityListScreenState
    extends State<AttendanceActivityListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch activities for Admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(context, listen: false)
          .fetchActivitiesAdmin(); // Dùng lại hàm fetch Admin
    });
  }

  // Helper to format date simply for the list
  String _formatSimpleDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn Hoạt động để xem Điểm danh'),
      ),
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

          return RefreshIndicator( // Thêm RefreshIndicator
            onRefresh: () => activityProvider.fetchActivitiesAdmin(),
            child: ListView.builder(
              itemCount: activityProvider.activities.length,
              itemBuilder: (context, index) {
                final activity = activityProvider.activities[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      activity.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ngày BĐ: ${_formatSimpleDate(activity.startDate)}'),
                          Text('Địa điểm: ${activity.location}'),
                          // Hiển thị số lượng đã đăng ký
                          Text(
                            'Đã đăng ký: ${activity.participantCount} / ${activity.maxParticipants > 0 ? activity.maxParticipants : 'Không giới hạn'}',
                            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor),
                    onTap: () {
                      // ĐIỀU HƯỚNG ĐẾN MÀN HÌNH CHI TIẾT ĐIỂM DANH
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceDetailScreen(
                            activity: activity, // Truyền hoạt động qua
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}