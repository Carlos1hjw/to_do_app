import 'package:flutter/material.dart';
import 'package:to_do_app/view/Homescreen/homescreen.dart';

void main(List<String> args) {
  runApp(const Myapp());
}
class Myapp extends StatefulWidget {
  const Myapp({super.key});

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
home: Homescreen(),
    );
  }
}