import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ebd_class.dart';
import '../models/ebd_attendance.dart';
import '../../../core/providers/service_providers.dart';

/// Provider que expõe a lista de todas as classes ativas
final ebdClassesListProvider = StreamProvider<List<EbdClass>>((ref) {
  final service = ref.watch(ebdClassServiceProvider);
  return service.watchClasses();
});

/// Provider que expõe o histórico de presenças de uma classe específica
final classAttendanceProvider = StreamProvider.family<List<EbdAttendance>, String>((ref, classId) {
  final service = ref.watch(ebdAttendanceServiceProvider);
  return service.watchAttendanceByClass(classId);
});

/// Provider que expõe o histórico de presenças de um membro específico
final memberAttendanceProvider = StreamProvider.family<List<EbdAttendance>, String>((ref, memberId) {
  final service = ref.watch(ebdAttendanceServiceProvider);
  return service.watchAttendanceByMember(memberId);
});
