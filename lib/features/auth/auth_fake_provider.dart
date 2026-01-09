import 'package:flutter_riverpod/flutter_riverpod.dart';

/// false = não autenticado
/// true  = autenticado
final fakeAuthStateProvider = StateProvider<bool>((ref) => false);
