class Course {
  final String id;
  final String name;
  final String facultyId;
  final String semester;

  Course({
    required this.id,
    required this.name,
    required this.facultyId,
    required this.semester,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      facultyId: json['facultyId'] ?? '',
      semester: json['semester'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'facultyId': facultyId, 'semester': semester};
  }
}
