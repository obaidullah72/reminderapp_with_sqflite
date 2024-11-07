import 'package:flutter/material.dart';
import 'package:reminderapp_with_sqflite/database/db_helper.dart';
import 'package:reminderapp_with_sqflite/screens/add_edit_reminder.dart';
import 'package:reminderapp_with_sqflite/screens/reminder_detail.dart';
import 'package:reminderapp_with_sqflite/services/notifications_helper.dart';
import 'package:reminderapp_with_sqflite/services/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestNotificationPermission();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await DBHelper.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  Future<void> _toggleReminder(int id, bool isActive) async {
    await DBHelper.toggleReminder(id, isActive);
    if (isActive) {
      final reminder = _reminders.firstWhere((rem) => rem['id'] == id);
      NotificationsHelper.scheduleNotification(id, reminder['title'],
          reminder['category'], DateTime.parse(reminder['reminderTime']));
    } else {
      NotificationsHelper.cancelNotification(id);
    }

    _loadReminders();
  }

  Future<void> deleteReminder(int id) async {
    await DBHelper.deleteReminder(id);
    NotificationsHelper.cancelNotification(id);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Reminders",
            style: TextStyle(
              color: Colors.teal,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.teal,
          ),
        ),
        body: _reminders.isEmpty
            ? Center(
                child: Text(
                  "No Reminders found",
                  style: TextStyle(fontSize: 18, color: Colors.teal),
                ),
              )
            : ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Dismissible(
                    key: Key(reminder['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      padding: EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmationDialog(context);
                    },
                    onDismissed: (direction) {
                      deleteReminder(reminder['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Reminder Deleted')));
                    },
                    child: Card(
                      color: Colors.teal.shade50,
                      elevation: 6,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ReminderDetailScreen(reminderId: reminder['id'],)));
                        },
                        leading: Icon(
                          Icons.notifications_outlined,
                          color: Colors.teal,
                        ),
                        title: Text(
                          reminder['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        subtitle: Text(
                          "Category: ${reminder['category']}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        trailing: Switch(
                          value: reminder['isActive' ] == 1,
                          activeColor: Colors.teal,
                          inactiveThumbColor: Colors.teal.shade600,
                          inactiveTrackColor: Colors.white,
                          onChanged: (value) {
                            _toggleReminder(reminder['id'], value);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddEditReminder()));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.teal.shade600,
          title: Text("Delete Reminder"),
          content: Text("Are you sure you want to delete this reminder?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
