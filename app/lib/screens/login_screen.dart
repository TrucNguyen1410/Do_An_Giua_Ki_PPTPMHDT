import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'student_home.dart';
import 'admin_home.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final void Function(bool)? onThemeToggle;
  const LoginScreen({super.key, this.onThemeToggle});
  @override State<LoginScreen> createState()=>_LoginState();
}

class _LoginState extends State<LoginScreen>{
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading=false;
  final _auth = AuthService();

  Future<void> _submit() async {
    setState(()=>_loading=true);
    try{
      final u = await _auth.login(_email.text.trim(), _pass.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_)=> u.role=='admin' ? AdminHome(onThemeToggle: widget.onThemeToggle)
                                       : StudentHome(onThemeToggle: widget.onThemeToggle),
      ));
    }catch(e){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    setState(()=>_loading=false);
  }

  @override Widget build(BuildContext ctx){
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller:_email, decoration: const InputDecoration(labelText:'Email')),
          TextField(controller:_pass, decoration: const InputDecoration(labelText:'Mật khẩu'), obscureText: true),
          const SizedBox(height:12),
          ElevatedButton(onPressed: _loading?null:_submit, child: Text(_loading?'Đang xử lý...':'Đăng nhập')),
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> const RegisterScreen()));
          }, child: const Text('Chưa có tài khoản? Đăng ký'))
        ]),
      ),
    );
  }
}
