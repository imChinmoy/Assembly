import 'package:client/core/utils/dummy.dart';
import 'package:client/features/home/model/student_model.dart';

class StudentRepo {
  Future<List<StudentModel>>getStudents() async {
    await Future.delayed(const Duration(seconds: 1));
    return students.map((student)=> StudentModel.fromJson(student)).toList();
  }

  // Future<StudentModel> updateStudent({required String studentId, required bool isPresent}) async {
  //   await Future.delayed(const Duration(seconds: 1));
    
  // }
}