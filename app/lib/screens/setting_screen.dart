import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingScreen extends StatefulWidget {
  final void Function(bool)? onThemeToggle;
  const SettingScreen({super.key, this.onThemeToggle});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _dark = false;
  Map<String, dynamic>? _profile;
  final _auth = AuthService();
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }
  Future<void> _load() async {
    final p = await _auth.getProfile();
    final h = await _auth.myRegistrations();
    setState(() { _profile = p; _history = h; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
      ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(_profile?['name'] ?? 'Chưa cập nhật'),
            subtitle: Text('${_profile?['email'] ?? ''}\nMSSV: ${_profile?['studentId'] ?? '-'}'),
            isThreeLine: true,
          ),
          SwitchListTile(
            value: _dark,
            title: const Text('Chế độ tối'),
            onChanged: (v){ setState(() => _dark = v); widget.onThemeToggle?.call(v); },
          ),
          const Divider(),
          const ListTile(title: Text('Lịch sử đăng ký')),
          for (final r in _history)
            ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(r['activity']?['title'] ?? ''),
              subtitle: Text(r['createdAt']?.toString() ?? ''),
            ),
        ],
      ),
    );
  }
}
