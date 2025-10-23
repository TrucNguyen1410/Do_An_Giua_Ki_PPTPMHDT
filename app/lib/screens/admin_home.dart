import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'setting_screen.dart';
import 'activity_form.dart';

class AdminHome extends StatefulWidget {
  final void Function(bool)? onThemeToggle;
  const AdminHome({super.key, this.onThemeToggle});
  @override State<AdminHome> createState()=>_AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>{
  @override Widget build(BuildContext ctx){
    return Scaffold(
      appBar: AppBar(title: const Text('Quản trị hoạt động'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () async {
          await AuthService().logout();
          if (mounted) Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_)=> LoginScreen(onThemeToggle: widget.onThemeToggle)), (_)=>false);
        }),
      ]),
      body: ListView(children: [
        ListTile(
          leading: const Icon(Icons.event_note),
          title: const Text('Quản lý hoạt động'),
          subtitle: const Text('Thêm, sửa, xóa hoạt động'),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> const ActivityForm()));
          },
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> SettingScreen(onThemeToggle: widget.onThemeToggle)));
        },
        child: const Icon(Icons.settings),
      ),
    );
  }
}
