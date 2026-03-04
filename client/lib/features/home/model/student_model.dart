class StudentModel {
  final int? id;
  final int? teamId;
  final String name;
  final String email;
  final String phone;
  final String studentId;
  final String? rollNo;
  final String year;
  final String? gender;
  final String? branch;
  final bool isPresent;
  final DateTime? attendanceUpdatedAt;

  StudentModel({
    this.id,
    this.teamId,
    required this.name,
    required this.email,
    required this.phone,
    required this.studentId,
    this.rollNo,
    required this.year,
    this.gender,
    this.branch,
    required this.isPresent,
    this.attendanceUpdatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      teamId: json['team_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      studentId: json['student_no'] ?? '',
      rollNo: json['roll_no'],
      year: json['year'] ?? '',
      gender: json['gender'],
      branch: json['branch'],
      isPresent: json['is_present'] ?? false,
      attendanceUpdatedAt: json['attendance_updated_at'] != null
          ? DateTime.parse(json['attendance_updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'name': name,
      'email': email,
      'phone': phone,
      'student_no': studentId,
      'roll_no': rollNo,
      'year': year,
      'gender': gender,
      'branch': branch,
      'is_present': isPresent,
      'attendance_updated_at': attendanceUpdatedAt?.toIso8601String(),
    };
  }
}
