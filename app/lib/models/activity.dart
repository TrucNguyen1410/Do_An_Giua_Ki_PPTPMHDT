class Activity {
  final String id;
  final String title;
  final String location;
  final DateTime startTime, endTime, deadline;
  final bool isClosed;
  bool isRegistered;

  final String? semester;
  final int? points;
  final String? content;
  final int? capacity;

  Activity({
    required this.id,
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.deadline,
    this.isClosed = false,
    this.isRegistered = false,
    this.semester,
    this.points,
    this.content,
    this.capacity,
  });

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
        id: j['_id'] ?? j['id'],
        title: j['title'] ?? '',
        location: j['location'] ?? '',
        startTime: DateTime.parse(j['startTime']),
        endTime: DateTime.parse(j['endTime']),
        deadline: DateTime.parse(j['deadline']),
        isClosed: j['isClosed'] ?? false,
        isRegistered: j['isRegistered'] ?? false,
        semester: j['semester'],
        points: j['points'],
        content: j['content'],
        capacity: j['capacity'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'location': location,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'deadline': deadline.toIso8601String(),
        'isClosed': isClosed,
        'isRegistered': isRegistered,
        'semester': semester,
        'points': points,
        'content': content,
        'capacity': capacity,
      };
}
