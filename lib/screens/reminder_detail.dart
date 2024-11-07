import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:reminderapp_with_sqflite/database/db_helper.dart';
import 'package:reminderapp_with_sqflite/screens/add_edit_reminder.dart';

class ReminderDetailScreen extends StatefulWidget {
  final int reminderId;

  const ReminderDetailScreen({super.key, required this.reminderId});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
        future: DBHelper.getRemindersById(widget.reminderId),
        builder: (context, snapshot) {
          // Check for loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              ),
            );
          }

          // Check for error state
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          // Check for null data
          if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              body: Center(
                child: Text('No reminder found.'),
              ),
            );
          }

          final reminder = snapshot.data!; // Now we are sure it is not null

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.teal),
              title: Text(
                "Reminder Details",
                style: TextStyle(
                  color: Colors.teal,
                ),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard(
                      label: "Title",
                      icon: Icons.title,
                      content: reminder['title'] ?? 'No Title'),
                  Gap(20),
                  _buildDetailCard(
                      label: "Description",
                      icon: Icons.description,
                      content: reminder['description'] ?? 'No Description'),
                  Gap(20),
                  _buildDetailCard(
                      label: "Category",
                      icon: Icons.category,
                      content: reminder['category'] ?? 'No Category'),
                  Gap(20),
                  _buildDetailCard(
                      label: "Reminder Time",
                      icon: Icons.access_time,
                      content: DateFormat('yyyy-MM-dd hh:mm a').format(
                          DateTime.parse(reminder['reminderTime'] ?? ''))),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.edit
              ),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditReminder(
                      reminderId: widget.reminderId,
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  Widget _buildDetailCard({
    required String label,
    required IconData icon,
    required String content,
  }) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.teal,
                ),
                Gap(10),
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Gap(10),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            )
          ],
        ),
      ),
    );
  }
}
