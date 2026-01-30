import 'package:flutter/material.dart';
import 'subject_model.dart';
import 'add_subject_page.dart';
import 'add_class_page.dart' as add_class;

void main() => runApp(const AttendanceApp());

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const AttendanceScreen(),
    );
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedIndex = 0; 
  final List<Map<String, dynamic>> todayClasses = [];
  final List<Subject> subjects = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        centerTitle: true,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subject),
            label: 'Subjects',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _selectedIndex == 0 ? const add_class.AddClassPage() : const AddSubjectPage(),
    ),
  );

  if (result != null) {
    setState(() {
      if (_selectedIndex == 0) {
        // Add to our class list
        todayClasses.add(result);
      } else {
        subjects.add(result);
      }
    });
  }
},
        child: const Icon(Icons.add),
      ),
    );
  }

  // FIXED: Cleaned up the duplicate Dashboard method
  Widget _buildDashboard() {
  if (todayClasses.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.language, size: 100, color: Colors.blueAccent),
          const SizedBox(height: 20),
          const Text("No classes today", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Use the + button to add a new class", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  return ListView.builder(
    itemCount: todayClasses.length,
    itemBuilder: (context, index) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF1E1E1E),
        child: ListTile(
          leading: const Icon(Icons.access_time, color: Colors.blue),
          title: Text(todayClasses[index]['subject']),
          subtitle: Text(todayClasses[index]['time']),
        ),
      );
    },
  );
}

  Widget _buildSubjectList() {
    return subjects.isEmpty
        ? const Center(child: Text('No subjects added yet'))
        : ListView.builder(
            itemCount: subjects.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              // LOGIC: Alternate colors based on index
              // Even rows get a deep grey, Odd rows get a slightly blueish tint
              final Color cardColor = index % 2 == 0 
                  ? const Color(0xFF1E1E1E) 
                  : const Color(0xFF252A34);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  // Added a subtle border to highlight the separation further
                  border: Border.all(color: Colors.white10, width: 0.5),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    subjects[index].name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("Goal: ${subjects[index].attendanceGoal.toInt()}% Attendance"),
    Text("Total Lectures: ${subjects[index].maxLectures}"),
  ],
),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
                ),
              );
            },
          );
  }
}