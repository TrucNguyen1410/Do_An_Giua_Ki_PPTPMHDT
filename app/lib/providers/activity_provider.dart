// lib/providers/activity_provider.dart
import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
// <-- 1. THÊM IMPORT MODEL MỚI -->
import '../models/attendance_record.dart'; 

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

  // --- HÀM ĐIỂM DANH SV (QUÉT QR) ---
  Future<void> markAttendance(String activityId) async {
    try {
      await _activityService.markAttendance(activityId);

      // Cập nhật state local
      final index = _activities.indexWhere((a) => a.id == activityId);
      if (index != -1) {
        // Cập nhật trạng thái đã đăng ký
        _activities[index].isRegistered = true; 
        // Cập nhật trạng thái đã điểm danh
        _activities[index].attended = true; // Giả định Activity Model có setter cho attended
      }
      
      // Cập nhật trong history
      final historyIndex = _history.indexWhere((a) => a.id == activityId);
      if (historyIndex != -1) {
          _history[historyIndex].attended = true;
      }
      
      notifyListeners();
    
    } catch (e) {
      print(e);
      throw e; 
    }
  }
  
  // --- HÀM MỚI CHO ADMIN (XEM DANH SÁCH ĐIỂM DANH) ---
  Future<List<AttendanceRecord>> fetchAttendanceList(String activityId) async {
    try {
      // Gọi service mới
      final list = await _activityService.fetchAttendanceList(activityId);
      return list;
    } catch (e) {
      print(e);
      throw Exception('Lỗi lấy danh sách điểm danh: ${e.toString()}');
    }
  }

  // --- ADMIN LOGIC ---
  
  // Hàm fetchActivitiesAdmin (gọi chung hàm fetchActivities)
  Future<void> fetchActivitiesAdmin() async {
    await fetchActivities();
  }

  Future<void> createActivity(Map<String, dynamic> data) async {
    try {
      final newActivity = await _activityService.createActivity(data);
      _activities.add(newActivity);
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> updateActivity(String id, Map<String, dynamic> data) async {
    try {
      final updatedActivity = await _activityService.updateActivity(id, data);
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
      _activities.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }
}