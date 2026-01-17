import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_suggestion.dart'; // Ensure this model exists

class SuggestionService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch suggestions matching the available time slot
  Future<List<ActivitySuggestion>> getSuggestions(int availableMinutes) async {
    List<ActivitySuggestion> combinedList = [];

    try {
      // 1. FETCH GLOBAL SUGGESTIONS (From 'suggestions' table)
      // We filter tasks that fit within the available time (e.g., if you have 30 mins, show tasks <= 30 mins)
      final globalData = await _client
          .from('suggestions')
          .select()
          .lte('min_duration', availableMinutes) // "Less than or equal to"
          .limit(5); // Get top 5 matches

      final globalSuggestions = globalData.map((e) => ActivitySuggestion(
        id: e['id'],
        title: e['title'],
        description: e['description'] ?? '',
        category: e['category'] ?? 'General',
        minDuration: e['min_duration'],
        type: e['type'] ?? 'Productive',
        resourceUrl: e['resource_url'] ?? '',
        resourceType: e['resource_type'] ?? 'Article',
      )).toList();

      combinedList.addAll(globalSuggestions);

      // 2. FETCH PERSONAL VAULT IDEAS (From 'ideas' table)
      // We convert your "Vault Ideas" into "Suggestions"
      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        final vaultData = await _client
            .from('ideas')
            .select()
            .eq('user_id', userId)
            .neq('status', 'Completed') // Don't suggest completed ideas
            .limit(3);

        final vaultSuggestions = vaultData.map((e) => ActivitySuggestion(
          id: e['id'],
          title: "Work on: ${e['title']}", // Add prefix to distinguish
          description: e['description'] ?? 'Continue working on this idea from your vault.',
          category: 'My Project',
          minDuration: 30, // Default duration for vault items
          type: 'Productive',
          resourceUrl: '', // Vault items might not have links yet
          resourceType: 'Project',
        )).toList();

        // Add personal ideas to the TOP of the list
        combinedList.insertAll(0, vaultSuggestions);
      }

    } catch (e) {
      print("Error fetching suggestions: $e");
    }

    return combinedList;
  }
}