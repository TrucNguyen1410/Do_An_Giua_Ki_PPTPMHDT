import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/activity.dart';
import '../services/activity_service.dart';

class AdminScannerScreen extends StatefulWidget {
  const AdminScannerScreen({super.key});

  @override
  State<AdminScannerScreen> createState() => _AdminScannerScreenState();
}

class _AdminScannerScreenState extends State<AdminScannerScreen> {
  final _svc = ActivityService();
  final MobileScannerController _controller = MobileScannerController();

  bool _busy = false;            // chặn quét liên tiếp
  String? _activityId;           // id hoạt động đang chọn
  List<Activity> _activities = []; // danh sách hoạt động để chọn

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      // Admin có thể điểm danh cho hoạt động đã mở (hoặc tất cả). Ở đây lấy tất cả.
      final list = await _svc.list(openOnly: false);
      if (!mounted) return;
      setState(() {
        _activities = list;
        if (_activities.isNotEmpty) {
          _activityId ??= _activities.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải hoạt động: $e')));
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final String? code =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;

    if (code == null || _activityId == null) return;

    setState(() => _busy = true);
    try {
      await _svc.adminCheckin(code, _activityId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Điểm danh thành công')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi điểm danh: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _activities.where((a) => a.id == _activityId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR điểm danh'),
        actions: [
          IconButton(
            onPressed: _loadActivities,
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại hoạt động',
          ),
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flashlight_on),
            tooltip: 'Bật/tắt đèn',
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Đổi camera',
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh chọn hoạt động
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.event_note),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _activityId,
                    decoration: const InputDecoration(
                      labelText: 'Chọn hoạt động',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _activities
                        .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.title, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _activityId = v),
                  ),
                ),
              ],
            ),
          ),

          // Khung camera quét
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                // viền hướng dẫn
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        width: 3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                if (_busy)
                  Container(
                    color: Colors.black.withOpacity(0.35),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),

          // Thông tin hoạt động đang chọn
          if (current != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Đang điểm danh: ${current.title} – ${current.location}',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// tiện ích nhỏ cho null-safety
extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
