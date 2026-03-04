import 'dart:developer';
import 'package:client/core/network/api_client.dart';
import 'package:client/features/home/model/student_model.dart';

class Datasource {
  final ApiClient client;

  Datasource(this.client);

  Future<List<StudentModel>> getStudents() async {
    try {
      final response = await client.get('/students');
      final List<dynamic> dataList = response['data'] ?? [];
      final students = dataList.map((json) => StudentModel.fromJson(json)).toList();
      log(students.toString());
      return students;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<Map<String, dynamic>> getStudentsPaginated({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      final response = await client.get('/students', queryParams: queryParams);
      final List<dynamic> dataList = response['data'] ?? [];
      final students = dataList.map((json) => StudentModel.fromJson(json)).toList();
      return {
        'data': students,
        'page': response['page'] ?? page,
        'totalPages': response['totalPages'] ?? 1,
        'totalPlayers': response['totalPlayers'] ?? 0,
      };
    } catch (e) {
      log(e.toString());
      return {'data': <StudentModel>[], 'page': 1, 'totalPages': 0, 'totalPlayers': 0};
    }
  }

  Future<StudentModel?> getStudentByStudentNo(String studentNo) async {
    try {
      final response = await client.get('/students/$studentNo');

      if (response['success'] == true) {
        return StudentModel.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<bool> updateAttendance({
    required String studentNo,
    required bool isPresent,
  }) async {
    try {
      final response = await client.patch('/students/attendance/$studentNo', {
        'is_present': isPresent,
      });

      return response['success'] == true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
