// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'subject_model.dart';
import 'dart:async';

class AddSubjectPage extends StatefulWidget {
  final Subject? existingSubject;

  const AddSubjectPage({super.key, this.existingSubject});

  @override
  State<AddSubjectPage> createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  final TextEditingController _nameController = TextEditingController();

  double _requiredAttendance = 75.0;
  final int _maxLectures = 45;
  int _lectureWeight = 1;
  int _tutorialWeight = 1;
  int _practicalWeight = 1;

  @override
  void initState() {
    super.initState();

    if (widget.existingSubject != null) {
      _nameController.text = widget.existingSubject!.name;
      _requiredAttendance = widget.existingSubject!.attendanceGoal;
    }
  }

  Timer? _timer;

  void _handleLongPress(VoidCallback onUpdate) {
    onUpdate();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      onUpdate();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timer?.cancel();
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
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty) {
                  Navigator.pop(
                    context,
                    Subject(
                      name: _nameController.text.trim(),
                      maxLectures: _maxLectures,
                      attendanceGoal: _requiredAttendance,

                      attended: widget.existingSubject?.attended ?? 0,
                      total: widget.existingSubject?.total ?? 0,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 28, color: Colors.white),
              decoration: InputDecoration(
                hintText: "Add subject name",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Text(
                    "${_requiredAttendance.toInt()}%",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Required attendance",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            Slider(
              value: _requiredAttendance,
              min: 0,
              max: 100,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey.shade800,
              onChanged: (value) => setState(() => _requiredAttendance = value),
            ),
            const SizedBox(height: 30),

            const Row(
              children: [
                Icon(Icons.balance, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Component weightage ratio",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.help_outline, color: Colors.white54, size: 20),
              ],
            ),
            const SizedBox(height: 20),

            _buildWeightSelector(
              "L",
              "LECTURE",
              _lectureWeight,
              (val) => setState(() => _lectureWeight = val),
            ),
            _buildWeightSelector(
              "T",
              "TUTORIAL",
              _tutorialWeight,
              (val) => setState(() => _tutorialWeight = val),
            ),
            _buildWeightSelector(
              "P",
              "PRACTICAL",
              _practicalWeight,
              (val) => setState(() => _practicalWeight = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSelector(
    String initial,
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade800,
            child: Text(initial, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, letterSpacing: 1.2),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE2F3D0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onLongPressStart: (_) => _handleLongPress(() {
                    if (value > 0) onChanged(value - 1);
                  }),
                  onLongPressEnd: (_) => _stopTimer(),
                  onTap: () => value > 0 ? onChanged(value - 1) : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(Icons.remove_circle, color: Color(0xFF8BC34A)),
                  ),
                ),
                Text(
                  "$value",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onLongPressStart: (_) => _handleLongPress(() {
                    onChanged(value + 1);
                  }),
                  onLongPressEnd: (_) => _stopTimer(),
                  onTap: () => onChanged(value + 1),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(Icons.add_circle, color: Color(0xFF8BC34A)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
