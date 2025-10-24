// lib/models/activity.dart

class Activity {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  // Thêm các trường khác nếu có...

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      date: DateTime.parse(json['date']), // API trả về date dạng String ISO
    );
  }
}