import '../models/activity.dart';
import 'api_client.dart';

class ActivityService {
  final _api = ApiClient();

  /// 🔹 Lấy danh sách hoạt động
  Future<List<Activity>> list({bool openOnly = true}) async {
    final data = await _api.get('/activities?open=${openOnly ? "true" : "false"}');
    return (data as List).map((e) => Activity.fromJson(e)).toList();
  }

  /// 🔹 Sinh viên đăng ký
  Future<void> register(String activityId) async {
    await _api.post('/activities/$activityId/register', {});
  }

  /// 🔹 Admin quét QR điểm danh
  Future<String> getAttendanceToken() async {
    final data = await _api.post('/admin/attendance/token', {});
    return data['token'];
  }

  Future<void> adminCheckin(String token, String activityId) async {
    await _api.post('/admin/attendance/checkin', {'token': token, 'activityId': activityId});
  }

  /// 🔹 Admin tạo hoạt động
  Future<void> create(Map<String, dynamic> data) async {
    print("📤 Gửi yêu cầu tạo hoạt động: $data");
    final result = await _api.post('/admin/activities', data);
    print("✅ Kết quả: $result");
  }

  /// 🔹 Admin cập nhật hoạt động
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _api.put('/admin/activities/$id', data);
  }

  /// 🔹 Admin xóa hoạt động
  Future<void> delete(String id) async {
    await _api.delete('/admin/activities/$id');
  }

  Future<void> unregister(String id) async {}
}
