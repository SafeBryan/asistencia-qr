class Faculty {
  final String id;
  final String name;
  final String universityId;

  Faculty({required this.id, required this.name, required this.universityId});

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'],
      name: json['name'],
      universityId: json['universityId'],
    );
  }
}
