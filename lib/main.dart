// ignore_for_file: unused_element, unused_local_variable, depend_on_referenced_packages, avoid_print, deprecated_member_use

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_class_page.dart';
import 'add_subject_page.dart';
import 'login_page.dart';
import 'notification_service.dart';
import 'subject_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const AttendanceScreen();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

DateTime _selectedDate = DateTime.now();

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> weeklyTimetable = [];
  final List<Subject> subjects = [];

  Map<String, String> attendanceHistory = {};
  late SharedPreferences _prefs;
  bool _showCalendar = true;
  bool _dailyReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Widget _buildSidePanel(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: const Color(0xFF121212),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "ACADEMIX",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.dashboard_rounded,
              color: Colors.blueAccent,
            ),
            title: const Text(
              "Attendance Tracker",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.assignment_rounded,
              color: Colors.white38,
            ),
            title: const Text(
              "Assignments",
              style: TextStyle(color: Colors.white38),
            ),
            onTap: () {
              Navigator.pop(context);
              _navigateToComingSoon(context);
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "v1.0.1-beta",
              style: TextStyle(
                color: Colors.white24,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Spacer(),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmLogout(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigateToComingSoon(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.sentiment_very_dissatisfied,
                  size: 100,
                  color: Colors.white24,
                ),
                SizedBox(height: 20),
                Text(
                  "Assignments",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Coming Soon...",
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();

    final timetableJson = _prefs.getString('weeklyTimetable');
    if (timetableJson != null) {
      final List<dynamic> decoded = jsonDecode(timetableJson);
      setState(() {
        weeklyTimetable.clear();
        weeklyTimetable.addAll(decoded.cast<Map<String, dynamic>>());
      });
    }

    final subjectsJson = _prefs.getString('subjects');
    if (subjectsJson != null) {
      final List<dynamic> decoded = jsonDecode(subjectsJson);
      setState(() {
        subjects.clear();
        for (var item in decoded) {
          subjects.add(
            Subject(
              name: item['name'],
              attended: item['attended'] ?? 0,
              total: item['total'] ?? 0,
              maxLectures: item['maxLectures'] ?? 45,
              attendanceGoal: (item['attendanceGoal'] ?? 75.0).toDouble(),
            ),
          );
        }
      });
    }

    final historyJson = _prefs.getString('attendanceHistory');
    if (historyJson != null) {
      setState(() {
        attendanceHistory = Map<String, String>.from(jsonDecode(historyJson));
      });
    }

    setState(() {
      _dailyReminder = _prefs.getBool('dailyReminderEnabled') ?? false;

      String? savedTime = _prefs.getString('reminderTimeValue');
      if (savedTime != null) {
        final parts = savedTime.split(':');
        _reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    });

    setState(() {});
  }

  Future<void> _saveData() async {
    await _prefs.setString('weeklyTimetable', jsonEncode(weeklyTimetable));
    await _prefs.setString('attendanceHistory', jsonEncode(attendanceHistory));

    final subjectsData = subjects
        .map(
          (s) => {
            'name': s.name,
            'attended': s.attended,
            'total': s.total,
            'maxLectures': s.maxLectures,
            'attendanceGoal': s.attendanceGoal,
          },
        )
        .toList();
    await _prefs.setString('subjects', jsonEncode(subjectsData));

    await _prefs.setBool('dailyReminderEnabled', _dailyReminder);

    String timeString =
        "${_reminderTime.hour}:${_reminderTime.minute.toString().padLeft(2, '0')}";
    await _prefs.setString('reminderTimeValue', timeString);
    print("⚙️ System State Saved.");
  }

  String _getTodayDay() {
    final days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return days[DateTime.now().weekday - 1];
  }

  List<Map<String, dynamic>> _getTodaysClasses() {
    final days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    String selectedDayName = days[_selectedDate.weekday - 1];

    return weeklyTimetable
        .where((classItem) => classItem['day'] == selectedDayName)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: _buildSidePanel(context),

      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white70),
          onPressed: () => _showSettingsMenu(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showCalendar ? Icons.expand_less : Icons.expand_more,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _showCalendar = !_showCalendar;
              });
            },
            tooltip: _showCalendar ? 'Hide Calendar' : 'Show Calendar',
          ),

          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white70),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildDashboard() : _buildSubjectList(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.subject), label: 'Subjects'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                if (_selectedIndex == 0) {
                  return AddClassPage(
                    existingTimetable: weeklyTimetable,
                    availableSubjects: subjects,
                  );
                } else {
                  return const AddSubjectPage();
                }
              },
            ),
          );

          if (result != null && result is Subject) {
            setState(() {
              subjects.add(result);
            });
            _saveData();
          } else if (_selectedIndex == 0) {
            setState(() {});
            _saveData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboard() {
    final todaysClasses = _getTodaysClasses();

    return SingleChildScrollView(
      child: Column(
        children: [
          AnimatedCrossFade(
            firstChild: _buildCalendarHeader(),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _showCalendar
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),

          if (todaysClasses.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  const Icon(
                    Icons.calendar_today,
                    size: 100,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No classes today",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Add classes to your weekly timetable",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todaysClasses.length,
              itemBuilder: (context, index) {
                final classItem = todaysClasses[index];
                final subject = _findSubject(classItem['subject']);

                return _buildClassCard(classItem, subject, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    final monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthNames[now.month - 1],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNames = ["M", "T", "W", "T", "F", "S", "S"];
              return SizedBox(
                width: 45,
                child: Center(
                  child: Text(
                    dayNames[index],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekday + 2;

              if (index < firstWeekday || dayNumber > daysInMonth) {
                return const SizedBox();
              }

              final cellDate = DateTime(now.year, now.month, dayNumber);
              final isSelected =
                  dayNumber == _selectedDate.day &&
                  now.month == _selectedDate.month;
              final isToday =
                  dayNumber == now.day && now.month == DateTime.now().month;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = cellDate;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    border: isToday && !isSelected
                        ? Border.all(color: Colors.blue, width: 1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "$dayNumber",
                      style: TextStyle(
                        color: isSelected || isToday
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to exit?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(
    Map<String, dynamic> classItem,
    Subject? subject,
    int index,
  ) {
    String dateKey =
        "${DateFormat('yyyy-MM-dd').format(_selectedDate)}_${classItem['subject']}_${classItem['startTime']}";

    final String attendance = attendanceHistory[dateKey] ?? 'notmarked';
    if (subject == null) {
      return ListTile(
        title: Text(
          "Subject ${classItem['subject']} not found in Subjects tab!",
        ),
      );
    }

    final int attended = subject.attended;
    final int total = subject.total;
    final double target = subject.attendanceGoal / 100;

    int lecturesToAttend = 0;
    int lecturesCanMiss = 0;
    bool isAboveTarget = true;

    if (total == 0) {
      isAboveTarget = true;
    } else if (attended / total >= target) {
      isAboveTarget = true;

      lecturesCanMiss = ((attended / target) - total).floor();
    } else {
      isAboveTarget = false;

      lecturesToAttend = ((target * total - attended) / (1 - target)).ceil();
    }

    final double percentage = total > 0 ? (attended / total * 100) : 0;

    return GestureDetector(
      onLongPress: () => _showClassOptions(classItem, subject),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classItem['startTime'] ?? '09:00 AM',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  classItem['endTime'] ?? '10:00 AM',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "L",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classItem['subject'] ?? 'Class',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            classItem['faculty'] ?? 'No faculty',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (total == 0)
                        const Text(
                          "No classes marked yet",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        )
                      else if (isAboveTarget)
                        Text(
                          "You can miss $lecturesCanMiss more lecture(s)",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        Text(
                          "Attend $lecturesToAttend more lecture(s) to reach ${subject.attendanceGoal.toInt()}%",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildAttendanceButton("Can", attendance == 'can', () {
                        if (attendance == 'can') return;

                        setState(() {
                          if (attendance == 'present') {
                            subject.attended--;
                            subject.total--;
                          } else if (attendance == 'absent') {
                            subject.total--;
                          }

                          attendanceHistory[dateKey] = 'can';
                        });
                        _saveData();
                      }),

                      _buildAttendanceButton("Abs", attendance == 'absent', () {
                        if (attendance == 'absent') return;

                        setState(() {
                          if (attendance == 'present') {
                            subject.attended--;
                          } else if (attendance == 'notmarked' ||
                              attendance == 'can') {
                            subject.total++;
                          }

                          attendanceHistory[dateKey] = 'absent';
                        });
                        _saveData();
                      }),

                      _buildAttendanceButton(
                        "Pre",
                        attendance == 'present',
                        () {
                          if (attendance == 'present') return;

                          setState(() {
                            if (attendance == 'absent') {
                              subject.attended++;
                            } else if (attendance == 'notmarked' ||
                                attendance == 'can') {
                              subject.total++;
                              subject.attended++;
                            }

                            attendanceHistory[dateKey] = 'present';
                          });
                          _saveData();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 4),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${percentage.toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade900 : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.white30,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (label == "Can")
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: isSelected ? Colors.blue : Colors.white54,
                  )
                else if (label == "Abs")
                  Icon(
                    Icons.cancel,
                    size: 14,
                    color: isSelected ? Colors.red : Colors.white54,
                  )
                else if (label == "Pre")
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: isSelected ? Colors.green : Colors.white54,
                  ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Subject? _findSubject(String? subjectName) {
    if (subjectName == null) return null;
    try {
      return subjects.firstWhere(
        (s) => s.name.trim().toLowerCase() == subjectName.trim().toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildSubjectList() {
    if (subjects.isEmpty) {
      return const Center(child: Text('No subjects added yet'));
    }

    List<Subject> sortedSubjects = List.from(subjects);

    sortedSubjects.sort((a, b) {
      double pctA = a.total > 0 ? (a.attended / a.total) : 0;
      double pctB = b.total > 0 ? (b.attended / b.total) : 0;
      return pctA.compareTo(pctB);
    });
    return ListView.builder(
      itemCount: sortedSubjects.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (context, index) {
        final subject = sortedSubjects[index];
        int originalIndex = subjects.indexOf(subject);

        final double percentage = subject.total > 0
            ? (subject.attended / subject.total * 100)
            : 0;

        final bool isSafe = percentage >= subject.attendanceGoal;
        final Color statusColor = isSafe ? Colors.green : Colors.redAccent;

        return GestureDetector(
          onLongPress: () => _showSubjectOptions(context, subject, index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(15),

              border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(color: statusColor, width: 3),
                ),
                child: Center(
                  child: Text(
                    "${percentage.toInt()}%",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                subject.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                "Goal: ${subject.attendanceGoal.toInt()}% | Total: ${subject.total}",
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showClassOptions(Map<String, dynamic> classItem, Subject? subject) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => ListTile(
        leading: const Icon(Icons.delete, color: Colors.red),
        title: const Text("Delete Class", style: TextStyle(color: Colors.red)),
        onTap: () {
          setState(() => weeklyTimetable.remove(classItem));
          _saveData();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSubjectOptions(BuildContext context, Subject subject, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              subject.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text(
              "Edit Subject Details",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              Navigator.pop(context);

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddSubjectPage(existingSubject: subject),
                ),
              );

              if (result != null && result is Subject) {
                setState(() {
                  subjects[index] = result;

                  subjects[index].attended = subject.attended;
                  subjects[index].total = subject.total;
                });
                _saveData();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              "Delete Subject",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              setState(() {
                subjects.removeAt(index);

                weeklyTimetable.removeWhere(
                  (item) =>
                      item['subject'].toString().toLowerCase() ==
                      subject.name.toLowerCase(),
                );
              });
              _saveData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${subject.name} deleted")),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "System Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 30),

                  _buildSettingTile(
                    icon: Icons.summarize_rounded,
                    title: "Daily Summary",
                    subtitle: "Poke for a daily attendance check",
                    value: _dailyReminder,
                    onChanged: (bool value) async {
                      setModalState(() => _dailyReminder = value);
                      setState(() => _dailyReminder = value);

                      if (value) {
                        await _syncDailySummaryToCloud();
                      } else {
                        await FirebaseFirestore.instance
                            .collection('reminders')
                            .doc('daily_check')
                            .delete();
                      }
                      await _saveData();
                    },
                  ),

                  if (_dailyReminder) ...[
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(
                        Icons.access_time_filled,
                        color: Colors.orangeAccent,
                      ),
                      title: const Text(
                        "Reminder Time",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        _reminderTime.format(context),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                        );
                        if (picked != null) {
                          setModalState(() => _reminderTime = picked);
                          setState(() => _reminderTime = picked);
                          await _syncDailySummaryToCloud();
                          _saveData();
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      tileColor: Colors.white.withOpacity(0.05),
                    ),
                  ],
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Note: Real-time notifications are currently optimized for local sessions. Cloud-based 24/7 background triggers are slated for v1.1.0 (Production Server deployment).",
                            style: TextStyle(
                              color: Colors.amber.shade200,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to exit?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              try {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
              } catch (e) {
                debugPrint("Guest Logout handled: $e");
              } finally {
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.blueAccent),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        value: value,
        activeColor: Colors.blueAccent,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _syncDailySummaryToCloud() async {
    if (!_dailyReminder) return;

    try {
      String? token = await FirebaseMessaging.instance.getToken();

      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        _reminderTime.hour,
        _reminderTime.minute,
      );

      String formattedTime = DateFormat('hh:mm a').format(dt);

      await FirebaseFirestore.instance
          .collection('reminders')
          .doc('daily_check')
          .set({
            'time': formattedTime,
            'token': token,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      print("🕒 Cloud Synced with Zero: $formattedTime");
    } catch (e) {
      print("❌ Daily Sync Error: $e");
    }
  }
}
