// lib/features/search/data/search_local_storage.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchLocalStorage {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 7;
  
  /// Get recent searches from local storage
  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      return searches;
    } catch (e) {
      debugPrint('❌ Error getting recent searches: $e');
      return [];
    }
  }
  
  /// Add a search to recent searches
  /// - Removes duplicates
  /// - Adds to the beginning of the list
  /// - Keeps only the last 7 searches
  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searches = prefs.getStringList(_recentSearchesKey) ?? [];
      
      // Remove if already exists (to avoid duplicates)
      searches.remove(query);
      
      // Add to the beginning
      searches.insert(0, query);
      
      // Keep only the last N searches
      if (searches.length > _maxRecentSearches) {
        searches = searches.sublist(0, _maxRecentSearches);
      }
      
      await prefs.setStringList(_recentSearchesKey, searches);
      debugPrint('✅ Added "$query" to recent searches');
    } catch (e) {
      debugPrint('❌ Error adding recent search: $e');
    }
  }
  
  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
      debugPrint('✅ Cleared all recent searches');
    } catch (e) {
      debugPrint('❌ Error clearing recent searches: $e');
    }
  }
  
  /// Remove a specific search from recent searches
  Future<void> removeRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searches = prefs.getStringList(_recentSearchesKey) ?? [];
      
      searches.remove(query);
      
      await prefs.setStringList(_recentSearchesKey, searches);
      debugPrint('✅ Removed "$query" from recent searches');
    } catch (e) {
      debugPrint('❌ Error removing recent search: $e');
    }
  }
}