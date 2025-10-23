import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class ActivityForm extends StatefulWidget {
  final Activity? activity; // thêm cho chỉnh sửa
  const ActivityForm({super.key, this.activity});

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final _svc = ActivityService();
  final t = TextEditingController(),
      s = TextEditingController(),
      p = TextEditingController(),
      c = TextEditingController(),
      l = TextEditingController(),
      cap = TextEditingController();
  DateTime? start, end, dl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    if (a != null) {
      t.text = a.title;
      s.text = a.semester ?? '';
      p.text = a.points?.toString() ?? '';
      c.text = a.content ?? '';
      l.text = a.location;
      cap.text = a.capacity?.toString() ?? '';
      start = a.startTime;
      end = a.endTime;
      dl = a.deadline;
    }
  }

  Future<void> _pick(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (d == null) return;
    final tm = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (tm == null) return;
    final dt = DateTime(d.year, d.month, d.day, tm.hour, tm.minute);
    setState(() => isStart ? start = dt : end = dt);
  }

  Future<void> _save() async {
    if (start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng chọn thời gian bắt đầu và kết thúc")));
      return;
    }

    setState(() => _saving = true);
    try {
      final data = {
        'title': t.text,
        'semester': s.text,
        'points': int.tryParse(p.text) ?? 0,
        'content': c.text,
        'location': l.text,
        'startTime': start!.toIso8601String(),
        'endTime': end!.toIso8601String(),
        'deadline': dl?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'capacity': int.tryParse(cap.text) ?? 100,
      };

      if (widget.activity == null) {
        await _svc.create(data);
      } else {
        await _svc.update(widget.activity!.id, data);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.activity == null ? 'Đã thêm hoạt động' : 'Đã cập nhật hoạt động')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.activity == null ? 'Thêm hoạt động' : 'Chỉnh sửa hoạt động')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: t, decoration: const InputDecoration(labelText: 'Tên hoạt động')),
          TextField(controller: s, decoration: const InputDecoration(labelText: 'Học kỳ')),
          TextField(controller: p, decoration: const InputDecoration(labelText: 'Điểm rèn luyện')),
          TextField(controller: c, decoration: const InputDecoration(labelText: 'Nội dung')),
          TextField(controller: l, decoration: const InputDecoration(labelText: 'Địa điểm')),
          ListTile(
              title: Text('Bắt đầu: ${start ?? '-'}'),
              onTap: () => _pick(true)),
          ListTile(
              title: Text('Kết thúc: ${end ?? '-'}'),
              onTap: () => _pick(false)),
          ListTile(
              title: Text('Hạn đăng ký: ${dl ?? '-'}'),
              onTap: () async {
                final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now());
                if (d != null) {
                  final tm = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (tm != null) {
                    setState(() =>
                        dl = DateTime(d.year, d.month, d.day, tm.hour, tm.minute));
                  }
                }
              }),
          TextField(controller: cap, decoration: const InputDecoration(labelText: 'Số lượng tối đa')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Đang lưu...' : 'Lưu'),
          )
        ],
      ),
    );
  }
}
