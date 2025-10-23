import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'setting_screen.dart';

class StudentHome extends StatefulWidget {
  final void Function(bool)? onThemeToggle;
  const StudentHome({super.key, this.onThemeToggle});
  @override State<StudentHome> createState()=>_StudentHomeState();
}

class _StudentHomeState extends State<StudentHome>{
  final _svc = ActivityService(); late Future<List<Activity>> _future;

  @override void initState(){ super.initState(); _future=_svc.list(openOnly: true); }

  Future<void> _register(Activity a) async {
    try { await _svc.register(a.id); setState(()=> a.isRegistered = true); }
    catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }
  Future<void> _unregister(Activity a) async {
    try { await _svc.unregister(a.id); setState(()=> a.isRegistered = false); }
    catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override Widget build(BuildContext ctx){
    return Scaffold(
      appBar: AppBar(title: const Text('Hoạt động đang mở'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: ()=> setState(()=> _future=_svc.list(openOnly:true))),
      ]),
      body: FutureBuilder<List<Activity>>(
        future: _future,
        builder: (_, snap){
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final df = DateFormat('dd/MM/yyyy HH:mm');
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('Không có hoạt động mở'));

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_,i){
              final a=list[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(a.title),
                  subtitle: Text('${a.location}\n${df.format(a.startTime)} - ${df.format(a.endTime)}\nHạn: ${df.format(a.deadline)}'),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: a.isClosed ? null : ()=> a.isRegistered ? _unregister(a) : _register(a),
                    style: ElevatedButton.styleFrom(backgroundColor: a.isRegistered? Colors.red : Colors.blue),
                    child: Text(a.isRegistered? 'Hủy đăng ký' : 'Đăng ký', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              );
            });
        }),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> SettingScreen(onThemeToggle: widget.onThemeToggle)));
        },
        child: const Icon(Icons.settings),
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(child: Text('Tài khoản')),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_)=> LoginScreen(onThemeToggle: widget.onThemeToggle)),
                  (_)=>false);
              }
            },
          )
        ]),
      ),
    );
  }
}
