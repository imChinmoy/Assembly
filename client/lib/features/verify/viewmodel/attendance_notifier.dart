import 'package:client/features/verify/repository/verification_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendanceNotifierProvider = AsyncNotifierProvider(
  () => AttendanceStateNotifier(),
);

class AttendanceStateNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return true;
  }

  Future<bool> updateAttendance(String studentId, bool isPresent) async {
    final result = await VerificationRepo().updateAttendance(
      studentId,
      isPresent,
    );
    return result;
  }

}
