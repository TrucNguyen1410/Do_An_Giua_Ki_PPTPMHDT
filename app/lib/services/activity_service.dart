import '../models/activity.dart';
import 'api_client.dart';

class ActivityService {
  final _api = ApiClient();

  Future<List<Activity>> list({bool openOnly = true}) async {
    final d = await _api.get('/activities?open=${openOnly ? "true" : "false"}');
    return (d as List).map((e) => Activity.fromJson(e)).toList();
  }

  Future<void> register(String id) async {
    await _api.post('/activities/$id/register', {});
  }

  Future<void> unregister(String id) async {
    await _api.post('/activities/$id/unregister', {});
  }

  // admin
  Future<void> create(Map<String, dynamic> data) async {
    await _api.post('/admin/activities', data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _api.put('/admin/activities/$id', data);
  }

  Future<void> delete(String id) async {
    await _api.delete('/admin/activities/$id');
  }
}
