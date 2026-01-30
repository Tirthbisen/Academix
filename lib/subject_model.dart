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
}