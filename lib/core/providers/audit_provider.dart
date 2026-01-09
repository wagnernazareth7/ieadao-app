import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audit/audit_service.dart';

final auditServiceProvider = Provider((ref) => AuditService());
