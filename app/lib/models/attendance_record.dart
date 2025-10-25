// lib/models/attendance_record.dart

class AttendanceRecord {
  final String studentId;
  final String fullName;
  final String email;
  final DateTime registrationDate; // Dùng ngày đăng ký làm mốc (API trả về createdAt)

  AttendanceRecord({
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.registrationDate,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentId: json['studentId'] ?? 'N/A',
      fullName: json['fullName'] ?? 'Không rõ tên',
      email: json['email'] ?? 'N/A',
      registrationDate: DateTime.parse(json['registrationDate']),
    );
  }

  static List<AttendanceRecord> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => AttendanceRecord.fromJson(json)).toList();
  }
}