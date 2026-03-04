import 'package:client/core/network/api_client.dart';
import 'package:client/data/datasource.dart';
import 'package:client/features/home/model/student_model.dart';

class StudentRepo {

  Datasource datasource = Datasource(ApiClient());

  Future<List<StudentModel>>getStudents() async {
    final result = await datasource.getStudents();
    return result;
  }

  Future<bool> updateAttendance(String studentNo, bool isPresent) async {
    final result = await datasource.updateAttendance(studentNo: studentNo, isPresent: isPresent);
    return result;
  }

  Future<StudentModel?> getStudentByStudentNo(String studentNo) async {
    final result = await datasource.getStudentByStudentNo(studentNo);
    return result;
  }

  Future<Map<String, dynamic>> getStudentsPaginated({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    return datasource.getStudentsPaginated(page: page, limit: limit, search: search);
  }
}