import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class ActivityForm extends StatefulWidget {
  final Activity? activity;
  const ActivityForm({super.key, this.activity});

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  final _svc = ActivityService();

  // Controllers
  final _title = TextEditingController();
  final _semester = TextEditingController();
  final _points = TextEditingController();
  final _content = TextEditingController();
  final _location = TextEditingController();
  final _maxStudents = TextEditingController();

  // Dates
  DateTime? _startTime;
  DateTime? _endTime;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    if (a != null) {
      _title.text = a.title;
      _semester.text = a.semester;
      _points.text = a.points.toString();
      _content.text = a.content;
      _location.text = a.location;
      _maxStudents.text = a.maxParticipants.toString();
      _startTime = a.startTime;
      _endTime = a.endTime;
      _deadline = a.deadline;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "title": _title.text.trim(),
      "semester": _semester.text.trim(),
      "points": int.tryParse(_points.text.trim()) ?? 0,
      "content": _content.text.trim(),
      "location": _location.text.trim(),
      "startTime": _startTime?.toIso8601String(),
      "endTime": _endTime?.toIso8601String(),
      "deadline": _deadline?.toIso8601String(),
      "maxParticipants": int.tryParse(_maxStudents.text.trim()) ?? 0,
    };

    if (widget.activity == null) {
      await _svc.create(data);
    } else {
      await _svc.update(widget.activity!.id, data);
    }

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lưu hoạt động thành công")));
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickDate({
    required String label,
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    // ⚠ Không gọi setState trong build() khi chọn ngày
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      onPicked(picked);
      setState(() {}); // chỉ rebuild phần ngày hiển thị
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? "Thêm hoạt động" : "Sửa hoạt động"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: "Tên hoạt động"),
              validator: (v) => v!.isEmpty ? "Không được để trống" : null,
            ),
            TextFormField(controller: _semester, decoration: const InputDecoration(labelText: "Học kỳ")),
            TextFormField(
              controller: _points,
              decoration: const InputDecoration(labelText: "Điểm rèn luyện"),
              keyboardType: TextInputType.number,
            ),
            TextFormField(controller: _content, decoration: const InputDecoration(labelText: "Nội dung")),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: "Địa điểm")),

            const SizedBox(height: 12),

            // Thời gian chọn (tách riêng, tránh rebuild toàn form)
            ListTile(
              title: Text("Thời gian bắt đầu: ${_startTime != null ? _startTime!.toString().split(' ').first : 'Chưa chọn'}"),
              onTap: () => _pickDate(
                label: "Bắt đầu",
                current: _startTime,
                onPicked: (d) => _startTime = d,
              ),
            ),
            ListTile(
              title: Text("Thời gian kết thúc: ${_endTime != null ? _endTime!.toString().split(' ').first : 'Chưa chọn'}"),
              onTap: () => _pickDate(
                label: "Kết thúc",
                current: _endTime,
                onPicked: (d) => _endTime = d,
              ),
            ),
            ListTile(
              title: Text("Hạn đăng ký: ${_deadline != null ? _deadline!.toString().split(' ').first : 'Chưa chọn'}"),
              onTap: () => _pickDate(
                label: "Hạn đăng ký",
                current: _deadline,
                onPicked: (d) => _deadline = d,
              ),
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: _maxStudents,
              decoration: const InputDecoration(labelText: "Số lượng tối đa sinh viên"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text("Lưu hoạt động"),
            ),
          ],
        ),
      ),
    );
  }
}
