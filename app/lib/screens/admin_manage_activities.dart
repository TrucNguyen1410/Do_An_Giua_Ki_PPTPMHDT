import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import 'activity_form.dart';

class AdminManageActivitiesScreen extends StatefulWidget {
  const AdminManageActivitiesScreen({super.key});

  @override
  State<AdminManageActivitiesScreen> createState() => _AdminManageActivitiesScreenState();
}

class _AdminManageActivitiesScreenState extends State<AdminManageActivitiesScreen> {
  final _svc = ActivityService();
  late Future<List<Activity>> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.list();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _svc.list();
    });
  }

  void _openForm([Activity? act]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActivityForm(activity: act)),
    );
    if (result == true) _refresh();
  }

  void _delete(String id) async {
    final ok = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa hoạt động này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );
    if (ok == true) {
      await _svc.delete(id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý hoạt động")),
      body: FutureBuilder<List<Activity>>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text("Chưa có hoạt động nào"));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final a = list[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(a.title),
                  subtitle: Text("${a.location} (${a.points} điểm)"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(a)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(a.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
