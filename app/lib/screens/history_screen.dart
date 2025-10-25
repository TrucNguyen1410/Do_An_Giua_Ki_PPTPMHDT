// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:provider/provider.dart';
import '../models/activity.dart'; // Import the updated Activity model
import '../providers/activity_provider.dart';
import 'activity_detail_screen.dart'; // Import the detail screen

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch history when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(context, listen: false).fetchHistory();
    });
  }

  // Helper to format date simply for the list
  String _formatSimpleDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử Đăng ký'),
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, activityProvider, child) {
          if (activityProvider.isLoadingHistory) {
            return Center(child: CircularProgressIndicator());
          }

          if (activityProvider.historyError != null) {
            return Center(child: Text('Lỗi: ${activityProvider.historyError}'));
          }

          if (activityProvider.history.isEmpty) {
            return Center(child: Text('Bạn chưa đăng ký hoạt động nào.'));
          }

          // Display the list of registered activities
          return RefreshIndicator( // Added RefreshIndicator
            onRefresh: () => Provider.of<ActivityProvider>(context, listen: false).fetchHistory(),
            child: ListView.builder(
              itemCount: activityProvider.history.length,
              itemBuilder: (context, index) {
                final activity = activityProvider.history[index];
                final bool isFinished = DateTime.now().isAfter(activity.endDate);

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
                           Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                              SizedBox(width: 4),
                              Expanded(child: Text(activity.location, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                               Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                               SizedBox(width: 4),
                               // Display start date
                               Text('Ngày: ${_formatSimpleDate(activity.startDate)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Display Attendance Status as Trailing widget
                    trailing: Chip( // Luôn hiển thị trạng thái điểm danh trong lịch sử
                        label: Text(
                          activity.attended ? 'Đã điểm danh' : 'Chưa điểm danh',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: activity.attended ? Colors.green : (isFinished ? Colors.grey.shade600 : Colors.orange.shade700), // Cam nếu chưa diễn ra
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    onTap: () {
                      // Navigate to detail screen on tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Pass the specific activity object from history
                          builder: (context) => ActivityDetailScreen(
                            activity: activity,
                            isFromHistory: true, // <-- TRUYỀN CỜ NÀY
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