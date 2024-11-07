import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:reminderapp_with_sqflite/database/db_helper.dart';
import 'package:reminderapp_with_sqflite/screens/home_screen.dart';
import 'package:reminderapp_with_sqflite/services/notifications_helper.dart';

class AddEditReminder extends StatefulWidget {
  final int? reminderId;

  const AddEditReminder({super.key, this.reminderId});

  @override
  State<AddEditReminder> createState() => _AddEditReminderState();
}

class _AddEditReminderState extends State<AddEditReminder> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String _category = "Work";
  DateTime _reminderTime = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchReminder();
  }

  Future<void> fetchReminder() async {
    try {
      final data = await DBHelper.getRemindersById(widget.reminderId!);
      if (data != null) {
        _titleController.text = data['title'];
        _descriptionController.text = data['description'];
        _category = data['category'];
        _reminderTime = DateTime.parse(data['reminderTime']);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.teal),
        title: Text(
          widget.reminderId == null ? "Add Reminder" : "Edit Reminder",
          style: TextStyle(
            color: Colors.teal,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputCard(
                  label: "Title",
                  icon: Icons.title,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Enter Title",
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      value!.isEmpty ? "Please Enter A Title" : null;
                    },
                  ),
                ),
                Gap(20),
                _buildInputCard(
                  label: "Description",
                  icon: Icons.description,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter Description",
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      value!.isEmpty ? "Please Enter A Description" : null;
                    },
                  ),
                ),
                Gap(20),
                _buildInputCard(
                  label: "Category",
                  icon: Icons.category,
                  child: DropdownButtonFormField(
                    value: _category,
                    dropdownColor: Colors.teal.shade50,
                    decoration: InputDecoration.collapsed(hintText: ' '),
                    items: ["Work", "Personal", "Health", "Others"]
                        .map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                ),
                Gap(20),
                _buildDateTimerPicker(
                  label: "Date",
                  icon: Icons.calendar_today,
                  displayValue: DateFormat('yyyy-MM-dd').format(_reminderTime),
                  onPressed: _selectDate,
                ),
                _buildDateTimerPicker(
                    label: "Time",
                    icon: Icons.access_time,
                    displayValue: DateFormat('hh:mm a').format(_reminderTime),
                    onPressed: _selectTime,),
                Gap(20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ), textStyle: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16,
                    ),
                      backgroundColor: Colors.teal, foregroundColor: Colors.white,
                    ),
                    onPressed: _saveReminder,
                    child: Text("Save Reminder"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(
      {required String label, required IconData icon, required Widget child}) {
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
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimerPicker(
      {required String label,
      required IconData icon,
      required String displayValue,
      required Function() onPressed}) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.teal,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: TextButton(
          onPressed: onPressed,
          child: Text(
            displayValue,
            style: TextStyle(
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _reminderTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _reminderTime.hour,
          _reminderTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      ),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(
          _reminderTime.year,
          _reminderTime.month,
          _reminderTime.day,
          _reminderTime.hour,
          _reminderTime.minute,
        );
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newReminder = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'isActive': 1,
          'reminderTime': _reminderTime.toIso8601String(),
          'category': _category,
        };

        if (widget.reminderId == null) {
          final reminderId = await DBHelper.addReminder(newReminder);
          NotificationsHelper.scheduleNotification(
            reminderId,
            _titleController.text,
            _category,
            _reminderTime,
          );
        } else {
          await DBHelper.updateReminder(widget.reminderId!, newReminder);
          NotificationsHelper.scheduleNotification(
            widget.reminderId!,
            _titleController.text,
            _category,
            _reminderTime,
          );
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to HomeScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false, // This will remove all previous routes
        );
      } catch (e) {
        // Show error message
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save reminder. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
