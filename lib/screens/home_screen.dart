import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'diary_entry_screen.dart';
import 'profile_screen.dart';
import 'goals_screen.dart';
import 'expenses_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _hoveredCardDate;
  List<Map<String, dynamic>> _diaryEntries = [];

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'happy':
        return Colors.yellow;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'neutral':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchDiaryEntries() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('diary_entries')
            .where('userId', isEqualTo: user.uid)
            .orderBy('date', descending: true)
            .get();

        setState(() {
          _diaryEntries = snapshot.docs.map((doc) {
            return {
              'date': (doc['date'] as Timestamp).toDate(),
              'mood': doc['mood'],
              'title': doc['title'],
              'content': doc['content'],
            };
          }).toList();
        });
      } catch (e) {
        print("Error fetching diary entries: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDiaryEntries();
  }

  Widget _buildDiaryEntryCard(Map<String, dynamic> entry) {
    final isHovered = _hoveredCardDate == _formatDate(entry['date']);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCardDate = _formatDate(entry['date'])),
      onExit: (_) => setState(() => _hoveredCardDate = null),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        transformAlignment: Alignment.center,
        child: Card(
          color: _getMoodColor(entry['mood']),
          margin: EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child:ListTile(
            contentPadding: EdgeInsets.all(16.0),
            title: Text(entry['title'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_formatDate(entry['date'])}\n${entry['content']}'),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryEntryScreen(existingEntry: entry),
                ),
              ).then((_) {
                _fetchDiaryEntries(); // Refresh entries after editing
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _diaryEntries.isNotEmpty
            ? ListView.builder(
          itemCount: _diaryEntries.length,
          itemBuilder: (context, index) {
            final entry = _diaryEntries[index];
            return _buildDiaryEntryCard(entry);
          },
        )
            : Center(
          child: Text(
            'Add your first diary entry now using the button below...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        );
      case 1:
        return ProfileScreen();
      case 2:
        return GoalsScreen();
      case 3:
        return ExpensesScreen();
      default:
        return Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MeriDiary'),
        backgroundColor: Color(0xFF673AB7),
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? Color(0xFF673AB7) : Colors.grey,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 1 ? Color(0xFF673AB7) : Colors.grey,
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.flag,
              color: _selectedIndex == 2 ? Color(0xFF673AB7) : Colors.grey,
            ),
            label: 'My Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.attach_money,
              color: _selectedIndex == 3 ? Color(0xFF673AB7) : Colors.grey,
            ),
            label: 'My Expenses',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF673AB7),
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryEntryScreen()),
          ).then((_) => _fetchDiaryEntries());
        },
        backgroundColor: Color(0xFF673AB7),
        icon: Icon(Icons.add),
        label: Text(
          'Add New Entry',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
