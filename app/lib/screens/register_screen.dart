import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'student_home.dart';

class RegisterScreen extends StatefulWidget { const RegisterScreen({super.key});
  @override State<RegisterScreen> createState()=>_RegisterState();
}

class _RegisterState extends State<RegisterScreen>{
  final name=TextEditingController(), mssv=TextEditingController(),
        email=TextEditingController(), pass=TextEditingController();
  final _auth=AuthService(); bool _loading=false;

  Future<void> _submit() async{
    setState(()=>_loading=true);
    try{
      final u = await _auth.register(
        name: name.text, studentId: mssv.text, email: email.text, password: pass.text);
      if (mounted){
        Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_)=> const StudentHome()), (_)=>false);
      }
    }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    setState(()=>_loading=false);
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Họ tên')),
        TextField(controller: mssv, decoration: const InputDecoration(labelText: 'MSSV')),
        TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
        TextField(controller: pass, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _loading?null:_submit, child: Text(_loading?'Đang xử lý...':'Đăng ký'))
      ]),
    );
  }
}
