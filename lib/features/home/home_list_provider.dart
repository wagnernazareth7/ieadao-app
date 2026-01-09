import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeListProvider = FutureProvider<List<String>>((ref) async {
  // Simula delay de uma API ou Firestore
  await Future.delayed(const Duration(seconds: 2));
  return ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
});
