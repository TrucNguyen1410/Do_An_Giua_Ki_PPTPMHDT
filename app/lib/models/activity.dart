class Activity {
  final String id, title, semester, location, content;
  final DateTime startTime, endTime, deadline;
  final int points, capacity;
  final bool isClosed;

  Activity({
    required this.id, required this.title, required this.semester, required this.location, required this.content,
    required this.startTime, required this.endTime, required this.deadline,
    required this.points, required this.capacity, required this.isClosed
  });

  factory Activity.fromJson(Map<String,dynamic> j){
    return Activity(
      id: j['_id'],
      title: j['title'],
      semester: j['semester'],
      location: j['location'],
      content: j['content'] ?? "",
      startTime: DateTime.parse(j['startTime']),
      endTime: DateTime.parse(j['endTime']),
      deadline: DateTime.parse(j['deadline']),
      points: j['points'] ?? 0,
      capacity: j['capacity'] ?? 0,
      isClosed: j['isClosed'] ?? false
    );
  }

  int? get maxParticipants => null;

  get isRegistered => null;
}
