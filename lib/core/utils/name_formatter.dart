String normalizePlayerName(String input) {
  final compact = input.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (compact.isEmpty) return '';

  return compact
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) {
        final lower = part.toLowerCase();
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(' ');
}
