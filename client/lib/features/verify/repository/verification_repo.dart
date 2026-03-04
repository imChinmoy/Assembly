import 'package:client/core/network/api_client.dart';
import 'package:client/data/datasource.dart';

class VerificationRepo {
  Datasource datasource = Datasource(ApiClient());

  Future<bool> updateAttendance(String studentId, bool isPresent) async {
    final result = await datasource.updateAttendance(
      studentNo: studentId,
      isPresent: isPresent,
    );

    return result;
  }

}
