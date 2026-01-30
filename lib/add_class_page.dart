// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'subject_model.dart';

class AddClassPage extends StatefulWidget {
  final List<Map<String, dynamic>>? existingTimetable;
  final List<Subject> availableSubjects;

  const AddClassPage({
    super.key,
    this.existingTimetable,
    required this.availableSubjects,
  });

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  late TextEditingController _facultyController;

  final List<String> _days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  String _selectedDay = "Monday";
  String _startTime = "09:00 AM";
  String _endTime = "10:00 AM";
  String? _selectedSubjectName;

  @override
  void initState() {
    super.initState();

    _facultyController = TextEditingController();
  }

  @override
  void dispose() {
    _facultyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Add Weekly Class"),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            _addClassToParent();
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _addClassToParent();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed: () {
                    _addClassToParent();
                    _clearForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                  ),
                  child: const Text(
                    "Add More",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Subject",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedSubjectName,
                dropdownColor: const Color(0xFF252A34),
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white),
                items: widget.availableSubjects
                    .map(
                      (s) =>
                          DropdownMenuItem(value: s.name, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedSubjectName = val),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Day of Week",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedDay,
                dropdownColor: const Color(0xFF252A34),
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white),
                items: _days
                    .map(
                      (day) => DropdownMenuItem(value: day, child: Text(day)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedDay = val!),
              ),
            ),
            const SizedBox(height: 20),
            _buildTimeSection(
              "Start Time",
              _startTime,
              (t) => setState(() => _startTime = t),
            ),
            const SizedBox(height: 20),
            _buildTimeSection(
              "End Time",
              _endTime,
              (t) => setState(() => _endTime = t),
            ),
            const SizedBox(height: 20),
            const Text(
              "Faculty Name (Optional)",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _facultyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(
    String title,
    String time,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) onChanged(picked.format(context));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white54),
                const SizedBox(width: 12),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _clearForm() {
    setState(() {
      _facultyController.clear();
    });
  }

  void _addClassToParent() {
    if (widget.existingTimetable != null && _selectedSubjectName != null) {
      bool isDuplicate = widget.existingTimetable!.any(
        (item) =>
            item['subject'] == _selectedSubjectName &&
            item['day'] == _selectedDay &&
            item['startTime'] == _startTime,
      );

      if (isDuplicate) {
        return;
      }

      setState(() {
        widget.existingTimetable!.add({
          'subject': _selectedSubjectName,
          'day': _selectedDay,
          'startTime': _startTime,
          'endTime': _endTime,
          'faculty': _facultyController.text.trim(),
          'attendance': 'notmarked',
        });
      });
    }
  }
}
