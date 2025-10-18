class AppUser {
  final String id, name, email, role;
  final String? studentId;
  AppUser({required this.id, required this.name, required this.email, required this.role, this.studentId});

  factory AppUser.fromJson(Map<String,dynamic> j){
    return AppUser(
      id: j['id'] ?? j['_id'],
      name: j['name'],
      email: j['email'],
      role: j['role'],
      studentId: j['studentId'],
    );
  }
}
