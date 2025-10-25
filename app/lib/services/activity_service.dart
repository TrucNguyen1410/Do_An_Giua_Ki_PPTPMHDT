// lib/services/activity_service.dart
import '../models/activity.dart';
import 'api_client.dart';

class ActivityService {
  final ApiClient _apiClient = ApiClient();

  // --- STUDENT METHODS ---

  Future<List<Activity>> fetchActivities() async {
    try {
      final List<dynamic> responseData = await _apiClient.get('activities');
      return Activity.listFromJson(responseData);
    } catch (e) {
      throw Exception('Lỗi tải danh sách hoạt động: $e');
    }
  }

  Future<List<Activity>> fetchMyHistory() async {
    try {
      final List<dynamic> responseData = await _apiClient.get('activities/my-history');
      return Activity.listFromJson(responseData);
    } catch (e) {
      throw Exception('Lỗi tải lịch sử hoạt động: $e');
    }
  }

  Future<void> registerForActivity(String activityId) async {
    try {
      await _apiClient.post('activities/$activityId/register', {});
    } catch (e) {
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  Future<void> unregisterFromActivity(String activityId) async {
    try {
      await _apiClient.post('activities/$activityId/unregister', {});
    } catch (e) {
      throw Exception('Lỗi hủy đăng ký: $e');
    }
  }

  // --- ADMIN METHODS (CÁC HÀM BỊ THIẾU) ---

  // Hàm fetchActivitiesAdmin (gọi chung hàm fetchActivities)
  Future<List<Activity>> fetchActivitiesAdmin() async {
    return fetchActivities(); 
  }

  // Hàm tạo hoạt động
  Future<Activity> createActivity(Map<String, dynamic> data) async {
    try {
      final responseData = await _apiClient.post('activities', data);
      return Activity.fromJson(responseData);
    } catch (e) {
      throw Exception('Lỗi tạo hoạt động: $e');
    }
  }

  // Hàm cập nhật hoạt động
  Future<Activity> updateActivity(String id, Map<String, dynamic> data) async {
    try {
      final responseData = await _apiClient.put('activities/$id', data);
      return Activity.fromJson(responseData);
    } catch (e) {
      throw Exception('Lỗi cập nhật hoạt động: $e');
    }
  }

  // Hàm xóa hoạt động
  Future<void> deleteActivity(String id) async {
    try {
      await _apiClient.delete('activities/$id');
    } catch (e) {
      throw Exception('Lỗi xóa hoạt động: $e');
    }
  }
}