class Attendance {
  final String id;
  final String courseId;
  final String sectionId;
  final String classroomId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  Attendance({
    required this.id,
    required this.courseId,
    required this.sectionId,
    required this.classroomId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      sectionId: json['section_id'] ?? '',
      classroomId: json['classroom_id'] ?? '',
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'section_id': sectionId,
      'classroom_id': classroomId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
