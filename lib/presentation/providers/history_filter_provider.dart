import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected filter player ID (null = show all)
final historyFilterProvider = StateProvider<String?>((ref) => null);
