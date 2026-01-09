import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchTasks() async {
  final response = await _client
      .from('tasks')
      .select()
      .order('created_at');

  return List<Map<String, dynamic>>.from(response);
}
Future<void> createTask({
  required String title,
  int? estimatedMinutes,
  String? priority,
}) async {
  final userId = _client.auth.currentUser!.id;

  await _client.from('tasks').insert({
    'user_id': userId,
    'title': title,
    'estimated_minutes': estimatedMinutes,
    'priority': priority,
  });
}
Future<void> completeTask(String taskId) async {
  await _client
      .from('tasks')
      .update({'is_completed': true})
      .eq('id', taskId);
}
Future<void> deleteTask(String taskId) async {
  await _client
      .from('tasks')
      .delete()
      .eq('id', taskId);
}

}
