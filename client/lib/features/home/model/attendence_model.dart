class AttendenceModel {
  String? id;
  String? name;
  DateTime? date;
  String? time;
  String? isPresent;

  AttendenceModel({this.id, this.name, this.date, this.time, this.isPresent});

  factory AttendenceModel.fromJson(Map<String, dynamic> json) {
    return AttendenceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: json['date'] ?? DateTime.now().day,
      time: json['time'] ?? DateTime.now(),
      isPresent: json['isPresent'] ?? 'absent',
    );
  }
}