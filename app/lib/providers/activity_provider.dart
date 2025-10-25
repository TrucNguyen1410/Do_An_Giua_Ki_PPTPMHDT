// lib/providers/activity_provider.dart
import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityService _activityService = ActivityService();

  List<Activity> _activities = [];
  List<Activity> _history = [];
  bool _isLoadingActivities = false;
  bool _isLoadingHistory = false;
  String? _activitiesError;
  String? _historyError;

  Set<String> _loadingButtons = {};

  // Getters
  List<Activity> get activities => _activities;
  List<Activity> get history => _history;
  bool get isLoadingActivities => _isLoadingActivities;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get activitiesError => _activitiesError;
  String? get historyError => _historyError;
  bool isActivityLoading(String id) => _loadingButtons.contains(id);

  // --- STUDENT LOGIC ---

  Future<void> fetchActivities() async {
    _isLoadingActivities = true;
    _activitiesError = null;
    notifyListeners();
    try {
      _activities = await _activityService.fetchActivities();
    } catch (e) {
      _activitiesError = e.toString();
    }
    _isLoadingActivities = false;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();
    try {
      _history = await _activityService.fetchMyHistory();
    } catch (e) {
      _historyError = e.toString();
    }
    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<void> toggleRegistration(Activity activity) async {
    _loadingButtons.add(activity.id);
    notifyListeners();
    try {
      if (activity.isRegistered) {
        await _activityService.unregisterFromActivity(activity.id);
        activity.isRegistered = false;
        _history.removeWhere((a) => a.id == activity.id);
      } else {
        await _activityService.registerForActivity(activity.id);
        activity.isRegistered = true;
        if (!_history.any((a) => a.id == activity.id)) {
           _history.add(activity);
        }
      }
    } catch (e) {
      print(e);
      throw e;
    } finally {
      _loadingButtons.remove(activity.id);
      notifyListeners();
    }
  }

  // --- ADMIN LOGIC (PHẦN BỊ THIẾU) ---
  
  // Hàm fetchActivitiesAdmin (gọi chung hàm fetchActivities)
  Future<void> fetchActivitiesAdmin() async {
    // Chúng ta dùng chung hàm fetchActivities của student
    await fetchActivities();
  }

  Future<void> createActivity(Map<String, dynamic> data) async {
    try {
      final newActivity = await _activityService.createActivity(data);
      _activities.add(newActivity); // Thêm vào danh sách
      notifyListeners();
    } catch (e) {
      print(e);
      throw e; // Ném lỗi ra để form hiển thị
    }
  }

  Future<void> updateActivity(String id, Map<String, dynamic> data) async {
    try {
      final updatedActivity = await _activityService.updateActivity(id, data);
      // Cập nhật lại list
      final index = _activities.indexWhere((a) => a.id == id);
      if (index != -1) {
        _activities[index] = updatedActivity;
        notifyListeners();
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      await _activityService.deleteActivity(id);
      // Xóa khỏi list
      _activities.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }
}