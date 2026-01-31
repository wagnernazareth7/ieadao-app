import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ebd_class.dart';
import '../models/ebd_attendance.dart';
import '../models/ebd_certificate_model.dart';
import '../../../core/providers/service_providers.dart';
import '../../auth/providers/current_user_provider.dart';

/// Provider que expõe a lista de todas as classes ativas (Ordenação Resiliente)
final ebdClassesListProvider = StreamProvider<List<EbdClass>>((ref) {
  final service = ref.watch(ebdClassServiceProvider);
  
  return service.watchClasses().map((classes) {
    // BLINDAGEM SÉNIOR: Ordenação no cliente para evitar erros de índice no Firestore
    final sortedList = List<EbdClass>.from(classes);
    sortedList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sortedList;
  });
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

/// Provider que expõe as certificações do usuário logado (Blindado e Reativo)
final myCertificatesProvider = StreamProvider<List<EbdCertificate>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final service = ref.watch(ebdAttendanceServiceProvider);

  return userAsync.maybeWhen(
    data: (user) {
      if (user == null) return Stream.value([]);
      return service.watchMyCertificates(user.uid).map((certs) {
        // Ordena por data de emissão (mais recentes primeiro)
        final sortedCerts = List<EbdCertificate>.from(certs);
        sortedCerts.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
        return sortedCerts;
      });
    },
    orElse: () => Stream.value([]),
  );
});
