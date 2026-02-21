class ResponseExtractor {
  /// Returns first meaningful list found in a JSON response.
  static List<dynamic> list(dynamic raw) {
    // 1) If already a list, use it.
    if (raw is List) return raw;

    // 2) If map, try common keys first.
    if (raw is Map) {
      const priorityKeys = [
        'data',
        'packages',
        'treks',
        'blogs',
        'guides',
        'items',
        'results',
        'docs',
        'rows',
        'records',
      ];

      for (final key in priorityKeys) {
        final v = raw[key];
        if (v is List) return v;
      }

      // 3) Search nested maps/lists recursively.
      final found = _findFirstList(raw);
      if (found != null) return found;
    }

    return const [];
  }

  static List<dynamic>? _findFirstList(dynamic node) {
    if (node is List) {
      // Prefer non-empty lists, but allow empty list if it's the only list.
      if (node.isNotEmpty) return node;
      return node;
    }

    if (node is Map) {
      // Search values recursively.
      for (final value in node.values) {
        final found = _findFirstList(value);
        if (found != null) return found;
      }
    }

    return null;
  }
}
