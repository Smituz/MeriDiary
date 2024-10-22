import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DiaryEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? existingEntry; // Receive entry data (if editing)

  DiaryEntryScreen({this.existingEntry});

  @override
  _DiaryEntryScreenState createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'happy';
  final List<String> _moods = ['happy', 'sad', 'angry', 'neutral'];

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      // If editing an existing entry, preload its data
      _loadExistingEntry(widget.existingEntry!);
    }
  }

  void _loadExistingEntry(Map<String, dynamic> entry) {
    setState(() {
      _titleController.text = entry['title'];
      _contentController.text = entry['content'];
      _selectedDate = entry['date'];
      _selectedMood = entry['mood'];
    });
  }

  String _formatDateForFirestore(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _saveEntry() async {
    if (user == null) return;

    final formattedDate = _formatDateForFirestore(_selectedDate);
    final docId = '${user!.uid}_$formattedDate';

    await FirebaseFirestore.instance.collection('diary_entries').doc(docId).set({
      'title': _titleController.text,
      'content': _contentController.text,
      'mood': _selectedMood,
      'date': _selectedDate,
      'userId': user!.uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Diary entry saved!')),
    );
    Navigator.pop(context); // Return to HomeScreen after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diary Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Content',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                TextButton(
                  onPressed: () => showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  ).then((pickedDate) {
                    if (pickedDate == null) return;
                    setState(() => _selectedDate = pickedDate);
                  }),
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedMood,
              items: _moods.map((String mood) {
                return DropdownMenuItem(
                  value: mood,
                  child: Text(mood.capitalize()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() => _selectedMood = newValue!);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry,
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}
