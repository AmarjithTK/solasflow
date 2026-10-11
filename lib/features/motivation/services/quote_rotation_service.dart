// ============================================================================
// QuoteRotationService - Cycling logic for motivational quote selection
// ============================================================================
//
// Responsibilities:
// - Maintain rotation index per quote category/list
// - Return next quote in sequence (round-robin cycling)
// - Handle category fallback for unavailable/typo'd categories
// - Provide both list-based and map-based query interfaces
//
// Behavior:
// - Quotes follow list order and do not repeat until the list is exhausted.
// - Separate index maintained for each scoped category key.
// - Empty lists return fallback quote immediately.
// - Missing categories fall back to default (e.g., 'General').
//
// Example:
// ```dart
// final quotes = ['Tip 1', 'Tip 2', 'Tip 3'];
// service.nextQuoteForList('wellness', quotes, 'Default') // → 'Tip 1'
// service.nextQuoteForList('wellness', quotes, 'Default') // → 'Tip 2'
// service.nextQuoteForList('wellness', quotes, 'Default') // → 'Tip 3'
// service.nextQuoteForList('wellness', quotes, 'Default') // → 'Tip 1' (cycles)
// ```
//
// Benefits:
// - User perceives variety without random repetition
// - Quote order is retained per category across app launches.
// - Stateful cycling ensures fairness over time.
//
// Stateless Alternative:
// If quotes should be random instead, use Random().nextInt() instead of
// indexing. Current design favors cycling to ensure all quotes get equal
// airtime.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/pref_keys.dart';

class QuoteRotationService {
  static const _preferenceKey = PrefKeys.quoteRotationIndices;

  /// Track rotation index for each unique category/list.
  /// Key: category name or list identifier.
  /// Value: next index to select.
  final Map<String, int> _quoteIndexByCategory = {};
  SharedPreferences? _preferences;
  Future<void> _writeTail = Future<void>.value();
  bool _loaded = false;
  bool _persistenceReady = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final preferences = await SharedPreferences.getInstance();
      _preferences = preferences;
      _persistenceReady = true;
      final encoded = preferences.getString(_preferenceKey);
      if (encoded == null) return;
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('[DB] Ignoring invalid quote rotation preferences');
        return;
      }
      for (final entry in decoded.entries) {
        final index = entry.value;
        if (index is int && index >= 0) {
          _quoteIndexByCategory[entry.key] = index;
        }
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[ERROR] Could not load quote rotation preferences: $error\n$stackTrace',
      );
    }
  }

  Future<void> flush() => _writeTail;

  void _persistIndices() {
    if (!_persistenceReady) return;
    final encoded = jsonEncode(_quoteIndexByCategory);
    _writeTail = _writeTail
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint(
            '[ERROR] Previous quote rotation write failed: $error\n$stackTrace',
          );
        })
        .then((_) async {
          final preferences = _preferences ??=
              await SharedPreferences.getInstance();
          if (!await preferences.setString(_preferenceKey, encoded)) {
            throw StateError('SharedPreferences rejected quote rotation write');
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint(
            '[ERROR] Could not persist quote rotation preferences: '
            '$error\n$stackTrace',
          );
        });
  }

  /// Get next quote from a list with manual cycling
  ///
  /// Parameters:
  /// - key: Identifier for this quote list (stored in rotation index map)
  /// - quotes: List to cycle through
  /// - fallbackQuote: Returned if quotes list is empty
  ///
  /// Returns: Next quote in rotation sequence
  String nextQuoteForList({
    required String key,
    required List<String> quotes,
    required String fallbackQuote,
  }) {
    if (quotes.isEmpty) {
      return fallbackQuote;
    }

    final currentIndex = _quoteIndexByCategory[key] ?? 0;
    final selected = quotes[currentIndex % quotes.length];
    _quoteIndexByCategory[key] = currentIndex + 1;
    _persistIndices();
    return selected;
  }

  /// Get next quote from a category in the quotes map with automatic fallback
  ///
  /// Parameters:
  /// - category: Requested category (e.g., 'General', 'Focus', 'Malayalam')
  /// - quotesByCategory: Map of all available category → quotes lists
  /// - fallbackCategory: Category to use if requested category not found
  /// - fallbackQuote: Returned if fallbackCategory also empty or missing
  /// - rotationScope: Optional namespace keeping language/list cycles separate
  /// Returns: Next quote from requested or fallback category
  String nextQuoteFromMap({
    required String category,
    required Map<String, List<String>> quotesByCategory,
    required String fallbackCategory,
    required String fallbackQuote,
    String rotationScope = '',
  }) {
    final normalizedCategory = quotesByCategory.containsKey(category)
        ? category
        : fallbackCategory;

    final categoryQuotes = quotesByCategory[normalizedCategory] ?? const [];
    final key = rotationScope.isEmpty
        ? normalizedCategory
        : '$rotationScope:$normalizedCategory';
    return nextQuoteForList(
      key: key,
      quotes: categoryQuotes,
      fallbackQuote: fallbackQuote,
    );
  }
}
