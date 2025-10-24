// lib/services/activity_service.dart

import 'package:flutter/material.dart';
import 'api_client.dart';
import '../models/activity.dart'; 

class ActivityService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Activity> _activities = [];
  bool _isLoading = false;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // (Admin) Lấy tất cả hoạt động
  Future<void> fetchActivitiesAdmin() async {
    _setLoading(true);
    try {
      // Gọi đúng route: 'admin/activities'
      final responseData = await _apiClient.get('admin/activities'); 
      
      final List<dynamic> activityList = responseData;
      _activities = activityList.map((data) => Activity.fromJson(data)).toList();
      
    } catch (e) {
      print('Lỗi khi tải hoạt động (Admin): $e');
      rethrow; // Ném lỗi gốc ra
    } finally {
      _setLoading(false);
    }
  }

  // (Admin) Tạo hoạt động mới
  Future<void> createActivity(Map<String, dynamic> activityData) async {
    try {
      final newActivityData = await _apiClient.post('admin/activities', activityData);
      
      final newActivity = Activity.fromJson(newActivityData);
      _activities.insert(0, newActivity);
      
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tạo hoạt động: $e');
      rethrow; // Ném lỗi gốc ra
    }
  }

  // (Admin) Cập nhật hoạt động
  Future<void> updateActivity(String id, Map<String, dynamic> activityData) async {
    try {
      final updatedActivityData = await _apiClient.put('admin/activities/$id', activityData);
      
      final updatedActivity = Activity.fromJson(updatedActivityData);
      final index = _activities.indexWhere((act) => act.id == id);
      if (index != -1) {
        _activities[index] = updatedActivity;
        notifyListeners();
      }
    } catch (e) {
      print('Lỗi khi cập nhật hoạt động: $e');
      rethrow; // Ném lỗi gốc ra
    }
  }

  // (Admin) Xóa hoạt động
  Future<void> deleteActivity(String id) async {
    try {
      await _apiClient.delete('admin/activities/$id');
      
      _activities.removeWhere((act) => act.id == id);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi xóa hoạt động: $e');
      rethrow; // Ném lỗi gốc ra
    }
  }
}