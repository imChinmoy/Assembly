import 'dart:async';

import 'package:client/features/home/model/student_model.dart';
import 'package:client/features/home/repository/student_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentNotifierProvider = AsyncNotifierProvider(
  () => StudentStateNotifier(),
);

class StudentStateNotifier  extends AsyncNotifier{
  @override
  FutureOr<dynamic> build() {
    state = const AsyncValue.loading();
    return fetchStudents();
  }

  Future<List<StudentModel>> fetchStudents() async {
    final result = await StudentRepo().getStudents();
    return result;
  }

  Future<bool> updateAttendance(String studentNo, bool isPresent) async {
    final result = await StudentRepo().updateAttendance(studentNo, isPresent);
    return result;
  }

  Future<StudentModel?> getStudentByStudentNo(String studentNo) async {
    final result = await StudentRepo().getStudentByStudentNo(studentNo);
    return result;
  }

  Future<AsyncValue<List<StudentModel>>> refresh() async {
    state = const AsyncValue.loading();
    await fetchStudents();
    state = AsyncValue.data(await fetchStudents());
    return state as AsyncValue<List<StudentModel>>;
  }

}