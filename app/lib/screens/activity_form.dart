// lib/screens/activity_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';

class ActivityFormScreen extends StatefulWidget {
  final Activity? activity; // Null_able: Nếu null là tạo mới, nếu có là sửa

  const ActivityFormScreen({Key? key, this.activity}) : super(key: key);

  @override
  _ActivityFormScreenState createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- 1. THAY THẾ BIẾN DATE ---
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _maxParticipantsController;
  // Ba biến DateTime mới
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? _selectedRegistrationDeadline;
  // -----------------------------

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.activity != null;

    // Khởi tạo giá trị
    _nameController = TextEditingController(text: _isEditMode ? widget.activity!.name : '');
    _descriptionController = TextEditingController(text: _isEditMode ? widget.activity!.description : '');
    _locationController = TextEditingController(text: _isEditMode ? widget.activity!.location : '');
    _maxParticipantsController = TextEditingController(
        text: _isEditMode && widget.activity!.maxParticipants > 0
            ? widget.activity!.maxParticipants.toString()
            : '0');

    // --- 2. KHỞI TẠO 3 BIẾN DATE MỚI ---
    if (_isEditMode) {
      _selectedStartDate = widget.activity!.startDate;
      _selectedEndDate = widget.activity!.endDate;
      _selectedRegistrationDeadline = widget.activity!.registrationDeadline;
    }
    // ---------------------------------
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  // --- 3. HÀM CHỌN NGÀY/GIỜ CHUNG ---
  Future<DateTime?> _pickDateTime(BuildContext context, {required DateTime initialDate, bool pickTime = false}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020), // Cho phép chọn quá khứ (để demo)
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return null; // User hủy chọn ngày

    if (!pickTime) return pickedDate; // Chỉ chọn ngày

    if (!context.mounted) return pickedDate; // Kiểm tra context trước khi dùng

    // Nếu cần chọn cả giờ
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return pickedDate; // User hủy chọn giờ (giữ ngày đã chọn)

    // Kết hợp ngày và giờ
    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
  // ---------------------------------

  // Hàm Submit
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // --- 4. KIỂM TRA 3 BIẾN DATE MỚI ---
    if (_selectedStartDate == null || _selectedEndDate == null || _selectedRegistrationDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn đủ Ngày bắt đầu, Ngày kết thúc và Hạn chót đăng ký')),
      );
      return;
    }
    // (Thêm kiểm tra logic: ngày kết thúc > ngày bắt đầu, hạn chót <= ngày bắt đầu)
    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ngày kết thúc phải sau Ngày bắt đầu')),
      );
      return;
    }
     if (_selectedRegistrationDeadline!.isAfter(_selectedStartDate!)) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hạn chót đăng ký phải trước hoặc bằng Ngày bắt đầu')),
      );
      return;
    }
    // ---------------------------------

    setState(() { _isLoading = true; });

    // Tạo data object
    final Map<String, dynamic> data = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'maxParticipants': int.tryParse(_maxParticipantsController.text) ?? 0,
      // --- 5. GỬI 3 TRƯỜNG DATE MỚI LÊN API ---
      'startDate': _selectedStartDate!.toIso8601String(),
      'endDate': _selectedEndDate!.toIso8601String(),
      'registrationDeadline': _selectedRegistrationDeadline!.toIso8601String(),
      // ---------------------------------------
    };

    try {
      final provider = Provider.of<ActivityProvider>(context, listen: false);
      if (_isEditMode) {
        await provider.updateActivity(widget.activity!.id, data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật hoạt động thành công')),
        );
      } else {
        await provider.createActivity(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo hoạt động thành công')),
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // Helper để format ngày giờ
  String _formatDateTime(DateTime? dt, {bool showTime = false}) {
    if (dt == null) return 'Chưa chọn';
    final format = showTime ? DateFormat('dd/MM/yyyy HH:mm') : DateFormat('dd/MM/yyyy');
    return format.format(dt);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Sửa Hoạt động' : 'Tạo Hoạt động Mới'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Tên Hoạt động'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Mô tả'),
                        maxLines: 3,
                        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mô tả' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(labelText: 'Địa điểm'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập địa điểm' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxParticipantsController,
                        decoration: InputDecoration(
                          labelText: 'Số lượng tối đa',
                          hintText: '0 = không giới hạn'
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nhập số lượng (0 nếu không giới hạn)';
                          if (int.tryParse(value) == null) return 'Vui lòng nhập số hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // --- 6. BA NÚT CHỌN NGÀY/GIỜ ---
                      _buildDateTimePicker(
                        context: context,
                        label: 'Ngày bắt đầu:',
                        selectedDate: _selectedStartDate,
                        pickTime: true, // Chọn cả giờ
                        onDateSelected: (picked) => setState(() => _selectedStartDate = picked),
                      ),
                      const SizedBox(height: 16),
                       _buildDateTimePicker(
                        context: context,
                        label: 'Ngày kết thúc:',
                        selectedDate: _selectedEndDate,
                        pickTime: true, // Chọn cả giờ
                        onDateSelected: (picked) => setState(() => _selectedEndDate = picked),
                      ),
                      const SizedBox(height: 16),
                       _buildDateTimePicker(
                        context: context,
                        label: 'Hạn chót đăng ký:',
                        selectedDate: _selectedRegistrationDeadline,
                        pickTime: true, // Chọn cả giờ
                        onDateSelected: (picked) => setState(() => _selectedRegistrationDeadline = picked),
                      ),
                      // ------------------------------

                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(_isEditMode ? 'CẬP NHẬT' : 'TẠO MỚI'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // --- 7. WIDGET PHỤ TRỢ CHO VIỆC CHỌN NGÀY/GIỜ ---
  Widget _buildDateTimePicker({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required bool pickTime,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                _formatDateTime(selectedDate, showTime: pickTime),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              child: Text(selectedDate == null ? 'CHỌN' : 'THAY ĐỔI'),
              onPressed: () async {
                final picked = await _pickDateTime(
                  context,
                  initialDate: selectedDate ?? DateTime.now(),
                  pickTime: pickTime,
                );
                onDateSelected(picked); // Cập nhật state
              },
            ),
          ],
        ),
      ],
    );
  }
  // ---------------------------------------------
}
