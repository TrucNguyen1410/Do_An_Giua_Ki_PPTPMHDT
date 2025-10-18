import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'student_home.dart';

class RegisterScreen extends StatefulWidget { const RegisterScreen({super.key});
  @override State<RegisterScreen> createState()=>_RegisterScreenState(); }

class _RegisterScreenState extends State<RegisterScreen>{
  final _name = TextEditingController();
  final _mssv = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading=false;
  final _auth = AuthService();

  void _submit() async {
    setState(()=>_loading=true);
    try {
      await _auth.register(name:_name.text, studentId:_mssv.text, email:_email.text.trim(), password:_pass.text);
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const StudentHome()), (_) => false);
      }
    } catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    setState(()=>_loading=false);
  }

  @override Widget build(BuildContext ctx){
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller:_name, decoration: const InputDecoration(labelText:'Họ tên')),
        TextField(controller:_mssv, decoration: const InputDecoration(labelText:'MSSV')),
        TextField(controller:_email, decoration: const InputDecoration(labelText:'Email @hcmunre.edu.vn')),
        TextField(controller:_pass, decoration: const InputDecoration(labelText:'Mật khẩu'), obscureText: true),
        const SizedBox(height:12),
        ElevatedButton(onPressed: _loading?null:_submit, child: Text(_loading?'Đang xử lý...':'Tạo tài khoản')),
      ]),
    );
  }
}
