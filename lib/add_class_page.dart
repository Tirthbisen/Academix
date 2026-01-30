import 'package:flutter/material.dart';

class Subject {
  final String name;
  final double attendanceGoal;
  final int maxLectures;

  Subject({
    required this.name,
    required this.attendanceGoal,
    required this.maxLectures,
  });
}

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key});

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  late TextEditingController _nameController;
  bool _doesNotRepeat = true;
  String _selectedSubject = "Select subject...";
  String _startTime = "11:00 AM";
  String _endTime = "01:00 PM";
  double _requiredAttendance = 75.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty) {
                  Navigator.pop(
                    context,
                    Subject(
                      name: _nameController.text.trim(),
                      attendanceGoal: _requiredAttendance, // <--- PASS THE SLIDER VALUE
                      maxLectures: 45, // We will link this to L-T-P later
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildInputRow(Icons.school_outlined, _selectedSubject, onTap: () {
              // Logic to pick from your subjects list could go here
            }),
            _buildInputRow(Icons.category_outlined, "Class component", subText: "Select component..."),
            _buildInputRow(Icons.person_outline, "Add faculty name"),
            const Divider(color: Colors.white10, thickness: 1, indent: 70),
            _buildInputRow(Icons.calendar_today_outlined, "Sun, 25 Jan, 2026"),
            _buildInputRow(Icons.access_time, "Starts at", trailing: _startTime),
            _buildInputRow(Icons.access_time_filled, "Ends at", trailing: _endTime),
            
            // Repeat Toggle Row
            ListTile(
              leading: const Icon(Icons.repeat, color: Colors.white70),
              title: const Text("Does not repeat", style: TextStyle(color: Colors.white70)),
              trailing: Switch(
                value: _doesNotRepeat,
                activeColor: Colors.blue,
                onChanged: (val) => setState(() => _doesNotRepeat = val),
              ),
            ),
            
            _buildInputRow(Icons.link, "Add meeting link"),
            _buildInputRow(Icons.notes, "Add notes"),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(IconData icon, String title, {String? subText, String? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      subtitle: subText != null ? Text(subText, style: const TextStyle(color: Colors.white38)) : null,
      trailing: trailing != null ? Text(trailing, style: const TextStyle(color: Colors.white)) : null,
    );
  }
}