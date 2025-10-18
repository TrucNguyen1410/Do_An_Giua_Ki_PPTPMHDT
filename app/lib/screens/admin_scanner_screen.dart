import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/activity_service.dart';

class AdminScannerScreen extends StatefulWidget { const AdminScannerScreen({super.key});
  @override State<AdminScannerScreen> createState()=>_AdminScannerScreenState(); }

class _AdminScannerScreenState extends State<AdminScannerScreen>{
  final _ctrl = MobileScannerController();
  bool _busy = false;
  String? _activityId; // TODO: có thể chọn từ dropdown hoạt động

  @override void initState(){ super.initState(); _activityId = null; }

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_busy) return;
    final code = cap.barcodes.first.rawValue;
    if (code == null || _activityId == null) return;
    setState(()=>_busy = true);
    try {
      await ActivityService().adminCheckin(code, _activityId!);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Điểm danh ok')));
    } catch(e){
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(()=>_busy = false);
  }

  @override Widget build(BuildContext ctx){
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR điểm danh')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Nhập Activity ID (tạm thời)',
                hintText: 'Dán _id của hoạt động',
                border: OutlineInputBorder()
              ),
              onChanged: (v)=>_activityId = v.trim(),
            ),
          ),
          Expanded(
            child: MobileScanner(controller: _ctrl, onDetect: _onDetect),
          ),
        ],
      ),
    );
  }
}
