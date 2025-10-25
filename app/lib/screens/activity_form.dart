// lib/screens/activity_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart'; // Sửa: Dùng PROVIDER

class ActivityFormScreen extends StatefulWidget {
  final Activity? activity; // Nullable: nếu null là TẠO MỚI, có là SỬA

  const ActivityFormScreen({Key? key, this.activity}) : super(key: key);

  @override
  _ActivityFormScreenState createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  // Sửa: _titleController -> _nameController
  final _nameController = TextEditingController(); 
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      // Chế độ Sửa: điền thông tin cũ
      // Sửa: Dùng 'name' thay vì 'title'
      _nameController.text = widget.activity!.name;
      _descriptionController.text = widget.activity!.description;
      _locationController.text = widget.activity!.location;
      _selectedDate = widget.activity!.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final activityData = {
      'name': _nameController.text, // Sửa: Dùng 'name'
      'description': _descriptionController.text,
      'location': _locationController.text,
      'date': _selectedDate.toIso8601String(),
    };

    // Sửa: Dùng PROVIDER để gọi API
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

    try {
      if (widget.activity != null) {
        // Chế độ Sửa
        await activityProvider.updateActivity(widget.activity!.id, activityData);
      } else {
        // Chế độ Tạo mới
        await activityProvider.createActivity(activityData);
      }
      // Thành công, quay lại màn hình trước
      Navigator.of(context).pop();
    } catch (e) {
      // Hiển thị lỗi
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Có lỗi xảy ra'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? 'Tạo Hoạt động' : 'Sửa Hoạt động'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController, // Sửa: Dùng _nameController
                  decoration: InputDecoration(labelText: 'Tên Hoạt động'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên hoạt động';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Địa điểm'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa điểm';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          'Ngày diễn ra: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                    ),
                    TextButton(
                      child: Text('Chọn ngày'),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(widget.activity == null ? 'Tạo' : 'Cập nhật'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}