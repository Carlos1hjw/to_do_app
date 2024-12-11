import 'package:flutter/material.dart';
import 'package:to_do_app/view/Addscreen/addscreen.dart';
import 'package:to_do_app/dummydb.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Map<String, dynamic>> tasks = [];

  Future<void> fetchTasks() async {
    final data = await DatabaseHelper.instance.getTasks();
    setState(() {
      tasks = data;
    });
    print("Fetched tasks: $tasks");
  }

  Future<void> toggleTaskStatus(int id, int currentStatus) async {
    final updatedStatus = currentStatus == 0 ? 1 : 0;
    await DatabaseHelper.instance.updateTask(id, {'status': updatedStatus});
    fetchTasks();
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        foregroundColor: Colors.white,
        title: const Text("To Do"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addscreen(onTaskAdded: fetchTasks),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
              "Add a Note Here",
              style: TextStyle(fontSize: 20),
            ))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addscreen(
                            taskToEdit: task,
                            onTaskAdded: fetchTasks,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepPurple.shade100,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                task['status'] == 1
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: task['status'] == 1
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                toggleTaskStatus(task['id'], task['status']);
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task['title'],
                                  style: const TextStyle(fontSize: 25,color: Colors.blueAccent),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${task['date']}  ",
                                      style: const TextStyle(fontSize: 18,color: Colors.redAccent),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "${task['time']} ",
                                      style: const TextStyle(fontSize: 18,color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                await DatabaseHelper.instance
                                    .deleteTask(task['id']);
                                print("Task deleted: ${task['id']}");
                                fetchTasks();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
