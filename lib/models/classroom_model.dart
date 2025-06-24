class Classroom {
  final String id;
  final String name;
  final String building;
  final int floor;
  final int capacity;
  final String facultyId;
  final double locationLat;
  final double locationLng;

  Classroom({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.facultyId,
    required this.locationLat,
    required this.locationLng,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'],
      name: json['name'],
      building: json['building'],
      floor: json['floor'],
      capacity: json['capacity'],
      facultyId: json['facultyId'],
      locationLat: (json['locationLat'] as num).toDouble(),
      locationLng: (json['locationLng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'building': building,
      'floor': floor,
      'capacity': capacity,
      'facultyId': facultyId,
      'locationLat': locationLat,
      'locationLng': locationLng,
    };
  }
}
