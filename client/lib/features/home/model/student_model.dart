class StudentModel {
  final String name;
  final String email;
  final String phone;
  final String studentId;
  final String year;
  final bool isPresent;

  StudentModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.studentId,
    required this.year, required this.isPresent,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      studentId: json['student_id'],
      year: json['year'], isPresent: json['isPresent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'student_id': studentId,
      'year': year,
      'isPresent': isPresent
    };
  }
}
