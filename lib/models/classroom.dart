class Classroom {
  final String id;
  final String name;
  final String building;
  final int floor;
  final Map<String, double> coordinates;

  Classroom({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.coordinates,
  });

  // Factory constructor to create a Classroom from JSON data
  factory Classroom.fromJson(Map<String, dynamic> json) {
    // Ensure coordinates are properly converted to Map<String, double>
    final Map<String, dynamic>? coordsJson = json['coordinates'];
    final Map<String, double> coordinates = coordsJson != null
        ? { for (var e in coordsJson.entries) e.key : (e.value as num).toDouble() }
        : {};

    return Classroom(
      id: json['id'],
      name: json['name'],
      building: json['building'],
      floor: json['floor'],
      coordinates: coordinates,
    );
  }

  // Method to convert Classroom object back to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'building': building,
      'floor': floor,
      'coordinates': coordinates,
    };
  }
}