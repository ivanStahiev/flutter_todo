import 'package:flutter/material.dart';
import 'package:flutter_todo/pages/todo_screen.dart';
import 'package:flutter_todo/pages/main_screen.dart';
import 'package:flutter_todo/pages/questions.dart';
import 'package:flutter_todo/pages/question_detail.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/': (context) => MainScreen(), '/todo': (context) => Home(), '/question': (context) => Question()},
    ));
}