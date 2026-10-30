class NameFormatter {
  /// Extracts and formats a clean, human first name from email, username, or full name.
  /// Examples:
  /// - 'uabdullahi676@gmail.com' -> 'Abdullahi'
  /// - 'Uabdullahi676' -> 'Abdullahi'
  /// - 'abdullahi.usman@gmail.com' -> 'Abdullahi'
  /// - 'Aisha Mohammed' -> 'Aisha'
  /// - 'Fatima' -> 'Fatima'
  static String formatFirstName(String? raw, {String fallback = 'Valued Patron'}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    var str = raw.trim();

    // If it's explicitly 'guest' or 'valued guest'
    if (str.toLowerCase().contains('guest')) {
      return fallback;
    }

    // If it starts with Al-Nur
    if (str.toLowerCase().startsWith('al-nur')) {
      return 'Al-Nur Member';
    }

    // 1. If email, take the part before '@'
    if (str.contains('@')) {
      str = str.split('@').first.trim();
    }

    // 2. If full name with spaces, take the first word
    if (str.contains(' ')) {
      str = str.split(' ').first.trim();
    }

    // 3. Strip trailing numbers, underscores, dashes (e.g. uabdullahi676 -> uabdullahi)
    str = str.replaceAll(RegExp(r'[\d_-]+$'), '');

    // 4. If delimited by dots or underscores or hyphens, take first part
    if (str.contains('.') || str.contains('_') || str.contains('-')) {
      final parts = str.split(RegExp(r'[._-]')).where((p) => p.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        str = parts.first;
      }
    }

    // 5. Check for single-letter initial prefix (e.g. 'uabdullahi' -> 'abdullahi', 'm_ibrahim' -> 'ibrahim')
    final singleLetterPrefixMatch = RegExp(r'^[a-zA-Z]([a-zA-Z]{3,})$').firstMatch(str);
    if (singleLetterPrefixMatch != null) {
      final candidate = singleLetterPrefixMatch.group(1)!;
      final lower = candidate.toLowerCase();
      // Recognized Islamic & common names or stems
      if (lower.startsWith('abd') ||
          lower.startsWith('muh') ||
          lower.startsWith('moh') ||
          lower.startsWith('ahm') ||
          lower.startsWith('fat') ||
          lower.startsWith('ais') ||
          lower.startsWith('zai') ||
          lower.startsWith('mar') ||
          lower.startsWith('kha') ||
          lower.startsWith('bil') ||
          lower.startsWith('mus') ||
          lower.startsWith('yus') ||
          lower.startsWith('ism') ||
          lower.startsWith('idr') ||
          lower.startsWith('sul') ||
          lower.startsWith('has') ||
          lower.startsWith('hus') ||
          lower.startsWith('abu') ||
          lower.startsWith('ali') ||
          lower.startsWith('oth') ||
          lower.startsWith('uth') ||
          lower.startsWith('uma') ||
          lower.startsWith('haf') ||
          lower.startsWith('sal') ||
          lower.startsWith('nur') ||
          lower.startsWith('hab') ||
          lower.startsWith('zub')) {
        str = candidate;
      }
    }

    // 6. Clean string
    str = str.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (str.isEmpty) return fallback;

    // 7. Capitalize first letter, lowercase the rest
    return '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}';
  }

  /// Formats full display name cleanly
  static String formatDisplayName(String? raw, {String fallback = 'Al-Nur Member'}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final first = formatFirstName(raw, fallback: '');
    if (first.isEmpty) return fallback;
    return first;
  }
}

