class Subject {
  String name;
  int attended;
  int total;
  int maxLectures;
  double attendanceGoal;

  Subject({
    required this.name,
    this.attended = 0,
    this.total = 0,
    this.maxLectures = 45,
    this.attendanceGoal = 75.0,
  });

  
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
      attended: json['attended'] ?? 0,
      total: json['total'] ?? 0,
      maxLectures: json['maxLectures'] ?? 45,
      attendanceGoal: (json['attendanceGoal'] ?? 75.0).toDouble(),
    );
  }

  
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'attended': attended,
      'total': total,
      'maxLectures': maxLectures,
      'attendanceGoal': attendanceGoal
          .toDouble(), 
    };
  }
}
