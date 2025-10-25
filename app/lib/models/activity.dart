// lib/models/activity.dart

class Activity {
  final String id;
  final String name;
  final String description;
  final String location;
  
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;

  bool isRegistered; 
  bool attended; // <-- SỬA: BỎ 'final' để có thể thay đổi giá trị sau khi tạo
  final int maxParticipants; 
  final int participantCount; 

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    this.isRegistered = false,
    this.attended = false, // <-- SỬA: Bỏ final
    this.maxParticipants = 0, 
    this.participantCount = 0,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(String? dateString) {
      if (dateString == null) return DateTime.now(); 
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return Activity(
      id: json['_id'],
      name: json['name'] ?? 'Không có tên',
      description: json['description'] ?? '',
      location: json['location'] ?? 'Không rõ',
      
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      registrationDeadline: _parseDate(json['registrationDeadline']),
      
      isRegistered: json['isRegistered'] ?? false,
      attended: json['attended'] ?? false,
      maxParticipants: json['maxParticipants'] ?? 0,
      participantCount: json['participantCount'] ?? 0, 
    );
  }

  static List<Activity> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Activity.fromJson(json)).toList();
  }
}
