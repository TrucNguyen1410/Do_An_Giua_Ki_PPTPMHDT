// lib/models/activity.dart
import 'dart:convert'; // <-- LỖI LÀ Ở ĐÂY (PHẢI LÀ DẤU :)

// Hàm helper để parse một danh sách activities từ chuỗi JSON
List<Activity> activityFromJson(String str) =>
    List<Activity>.from(json.decode(str).map((x) => Activity.fromJson(x)));

class Activity {
  final String id;
  final String name; // <-- TÊN ĐÚNG LÀ 'name' (KHÔNG PHẢI 'title')
  final String description;
  final DateTime date;
  final String location;
  bool isRegistered;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    this.isRegistered = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'Không có tên', // <-- SỬA 'title' thành 'name'
      description: json['description'] ?? 'Không có mô tả',
      date: DateTime.parse(json['date']),
      location: json['location'] ?? 'Không rõ địa điểm',
      isRegistered: json['isRegistered'] ?? false,
    );
  }

  // Hàm helper để parse một danh sách (nếu API trả về list)
  static List<Activity> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => Activity.fromJson(item)).toList();
  }
}