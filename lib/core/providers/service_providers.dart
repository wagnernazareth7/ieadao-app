import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/services/user_service.dart';
import '../../features/membros/services/member_service.dart';
import '../../features/ebd/services/ebd_class_service.dart';
import '../../features/ebd/services/ebd_attendance_service.dart';

final userServiceProvider = Provider((ref) => UserService());
final memberServiceProvider = Provider((ref) => MemberService());
final ebdClassServiceProvider = Provider((ref) => EbdClassService());
final ebdAttendanceServiceProvider = Provider((ref) => EbdAttendanceService());
