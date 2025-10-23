import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class MyQrScreen extends StatefulWidget { const MyQrScreen({super.key});
  @override State<MyQrScreen> createState()=>_MyQrState(); }

class _MyQrState extends State<MyQrScreen>{
  final _auth=AuthService(); late Future<String> _f;

  @override void initState(){ super.initState(); _f=_auth.getMyQrData(); }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('QR điểm danh của tôi')),
      body: Center(
        child: FutureBuilder<String>(
          future: _f,
          builder: (_,snap){
            if(!snap.hasData) return const CircularProgressIndicator();
            return SelectableText(snap.data!, textAlign: TextAlign.center);
          }),
      ),
    );
  }
}
