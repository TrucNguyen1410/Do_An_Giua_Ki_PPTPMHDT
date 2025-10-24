// lib/screens/activity_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import gói intl
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class ActivityFormScreen extends StatefulWidget {
  final Activity? activity; // Null nghĩa là "Tạo mới", có data nghĩa là "Sửa"

  const ActivityFormScreen({Key? key, this.activity}) : super(key: key);

  @override
  _ActivityFormScreenState createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  String _errorMessage = '';

  // Controllers cho các trường
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate; // Biến để lưu ngày đã chọn

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      // Nếu là "Sửa", điền thông tin cũ vào form
      _isEditing = true;
      _titleController.text = widget.activity!.title;
      _descriptionController.text = widget.activity!.description;
      _locationController.text = widget.activity!.location;
      _selectedDate = widget.activity!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày (Popup)
  Future<void> _pickDate(BuildContext context) async {
    final initialDate = _selectedDate ?? DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(), // Không cho chọn ngày quá khứ
      lastDate: DateTime(2030),
    );

    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
        _errorMessage = ''; // Xóa lỗi (nếu có)
      });
    }
  }

  // Hàm Submit (Gửi đi)
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Nếu form không hợp lệ, không làm gì cả
    }
    // Bắt buộc phải chọn ngày
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn ngày diễn ra';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Gom dữ liệu từ form
    final activityData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      // === SỬA LỖI Ở ĐÂY ===
      // Chuyển DateTime thành String ISO 8601 để gửi cho API
      'date': _selectedDate!.toIso8601String(), 
    };

    try {
      final activityService = Provider.of<ActivityService>(context, listen: false);
      
      if (_isEditing) {
        // Cập nhật
        await activityService.updateActivity(widget.activity!.id, activityData);
      } else {
        // Tạo mới
        await activityService.createActivity(activityData);
      }
      
      // Nếu thành công, quay về màn hình trước
      if (mounted) {
         Navigator.of(context).pop();
      }

    } catch (e) {
      // Hiển thị lỗi
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa Hoạt động' : 'Tạo Hoạt động mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề hoạt động',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Địa điểm
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Địa điểm',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa điểm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mô tả
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // === SỬA PHẦN CHỌN NGÀY ===
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        _selectedDate == null
                            ? 'Chọn ngày diễn ra'
                            // Dùng intl để format ngày
                            : 'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _pickDate(context),
                      child: const Text('Chọn ngày'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Hiển thị lỗi (nếu có)
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Lỗi: $_errorMessage',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Nút Submit
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_isEditing ? 'Cập nhật' : 'Tạo mới'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}