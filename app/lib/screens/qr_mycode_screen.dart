import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/activity_service.dart';

class MyQrScreen extends StatefulWidget { const MyQrScreen({super.key});
  @override State<MyQrScreen> createState()=>_MyQrScreenState(); }

class _MyQrScreenState extends State<MyQrScreen>{
  String? _token;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final t = await ActivityService().getAttendanceToken();
      setState(()=>_token = t);
    } catch(e){ if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override Widget build(BuildContext ctx){
    return Scaffold(
      appBar: AppBar(title: const Text('QR điểm danh của tôi')),
      body: Center(
        child: _token==null ? const CircularProgressIndicator() : QrImageView(data: _token!, version: QrVersions.auto, size: 260),
      ),
    );
  }
}
