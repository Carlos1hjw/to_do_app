import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/dummydb.dart';
import 'package:to_do_app/view/Homescreen/homescreen.dart';

class Addscreen extends StatefulWidget {
  final Function onTaskAdded;
  final Map<String, dynamic>? taskToEdit;

  const Addscreen({
    super.key,
    required this.onTaskAdded,
    this.taskToEdit,
  });

  @override
  State<Addscreen> createState() => _AddscreenState();
}
class _AddscreenState extends State<Addscreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Map<String, dynamic>? taskToEdit;

  @override
  void initState() {
    super.initState();

    if (widget.taskToEdit != null) {
      taskToEdit = widget.taskToEdit;
      final task = taskToEdit!;
      _titleController.text = task['title'];
      _selectedDate = DateFormat('dd-MM-yyyy').parse(task['date']);
      _selectedTime = TimeOfDay(
        hour: int.parse(task['time'].split(':')[0]),
        minute: int.parse(task['time'].split(':')[1]),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
        timeController.text = _selectedTime.format(context);
      });
    }
  }

  void _handledatepicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
    }
  }

  void _handletimepicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
      timeController.text = _selectedTime.format(context);
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        final formattedTime = "${_selectedTime.hour}:${_selectedTime.minute}";
        if (taskToEdit == null) {
          await DatabaseHelper.instance.insertTask({
            'title': _titleController.text,
            'date': DateFormat('dd-MM-yyyy').format(_selectedDate),
            'time': formattedTime,
            'status': 0,
          });
        } else {
          await DatabaseHelper.instance.updateTask(
            taskToEdit!['id'],
            {
              'title': _titleController.text,
              'date': DateFormat('dd-MM-yyyy').format(_selectedDate),
              'time': formattedTime,
              'status': 0,
            },
          );
        }
        widget.onTaskAdded();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Homescreen()),
        );
      } catch (error) {
        print('Error saving task: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Add a Note",style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  filled: true,
                  fillColor: Colors.green.shade100,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: _handledatepicker,
                decoration: InputDecoration(
                  labelText: " Date",
                  filled: true,
                  fillColor: Colors.yellow.shade100,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a date";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: timeController,
                readOnly: true,
                onTap: _handletimepicker,
                decoration: InputDecoration(
                  labelText: "Time",
                  filled: true,
                  fillColor: Colors.red.shade100,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a time";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text("Save Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


