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
    AsyncLoading();
    return fetchStudents();
  }

  Future<List<StudentModel>> fetchStudents() async {
    await Future.delayed(const Duration(seconds: 1));
    return StudentRepo().getStudents();
  }

  // Future<StudentModel> updateStudent(StudentModel student) async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   return student;
  // }

}