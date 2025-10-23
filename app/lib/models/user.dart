class AppUser {
  final String id;
  final String? name;
  final String? studentId;
  final String email;
  final String role;

  AppUser({required this.id, required this.email, required this.role, this.name, this.studentId});

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] ?? j['_id'],
        name: j['name'],
        studentId: j['studentId'],
        email: j['email'],
        role: j['role'] ?? 'student',
      );
}
