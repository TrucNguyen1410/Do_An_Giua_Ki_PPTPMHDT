// lib/screens/attendance_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../models/attendance_record.dart'; // <-- ĐÃ ĐƯỢC TẠO

class AttendanceDetailScreen extends StatefulWidget {
  final Activity activity;

  const AttendanceDetailScreen({Key? key, required this.activity}) : super(key: key);

  @override
  _AttendanceDetailScreenState createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  bool _isLoading = false;
  String? _error;
  List<AttendanceRecord> _attendanceList = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceList();
  }

  Future<void> _fetchAttendanceList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Gọi Provider để lấy danh sách điểm danh
      final list = await Provider.of<ActivityProvider>(context, listen: false)
          .fetchAttendanceList(widget.activity.id);
      
      setState(() {
        _attendanceList = list;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách: ${e.toString().replaceAll("Exception: ", "")}'))
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SV Đã Điểm danh: ${widget.activity.name}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tổng số đã điểm danh: ${_attendanceList.length} / ${widget.activity.participantCount} (Đã đăng ký)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
            ),
          ),
          Divider(height: 1, thickness: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchAttendanceList,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Lỗi tải danh sách: $_error'));
    }
    if (_attendanceList.isEmpty) {
      return Center(child: Text('Chưa có sinh viên nào điểm danh.'));
    }

    return ListView.builder(
      itemCount: _attendanceList.length,
      itemBuilder: (context, index) {
        final record = _attendanceList[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text((index + 1).toString()), // Số thứ tự
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            foregroundColor: Theme.of(context).primaryColor,
          ),
          title: Text(record.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${record.studentId} - ${record.email}'),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                 'Đã ĐD', // Đã điểm danh
                 style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
              ),
              Text(
                // Hiển thị thời gian điểm danh
                DateFormat('HH:mm').format(record.registrationDate.toLocal()), 
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}