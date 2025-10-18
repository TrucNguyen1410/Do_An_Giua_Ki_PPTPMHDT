import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import 'qr_mycode_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class StudentHome extends StatefulWidget {
  final void Function(bool)? onThemeToggle; // ⚡ nhận callback đổi theme
  const StudentHome({super.key, this.onThemeToggle});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final _svc = ActivityService();
  late Future<List<Activity>> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.list(openOnly: true);
  }

  // 🔹 Đăng ký hoạt động
  Future<void> _register(String id) async {
    try {
      await _svc.register(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công')),
        );
      }
      setState(() => _future = _svc.list(openOnly: true));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // 🔹 Hủy đăng ký hoạt động
  Future<void> _unregister(String id) async {
    try {
      await _svc.unregister(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy đăng ký hoạt động')),
        );
      }
      setState(() => _future = _svc.list(openOnly: true));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoạt động đang mở'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: "Mã QR của tôi",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyQrScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Activity>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Lỗi: ${snap.error}"));
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("Không có hoạt động nào mở"));
          }

          final df = DateFormat('dd/MM/yyyy HH:mm');

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final a = list[i];
              final isRegistered = a.isRegistered == true;

              return Card(
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    a.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${a.location}\n${df.format(a.startTime)} - ${df.format(a.endTime)}\nHạn: ${df.format(a.deadline)}',
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: a.isClosed
                        ? null
                        : () => isRegistered
                            ? _unregister(a.id)
                            : _register(a.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isRegistered ? Colors.red : Colors.blue,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: Text(
                      isRegistered ? 'Hủy đăng ký' : 'Đăng ký',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
