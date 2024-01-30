import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? file;
  FilePickerResult? result;
  var imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xff0051D3),
          title: Text(
            'Главная',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 50)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (file != null || result != null) ...[
                if (!kIsWeb) ...[
                  CircleAvatar(radius: 150, child: Image.file(file!, height: 150, width: 150, fit: BoxFit.fill),),
                ],
                const SizedBox(height: 8),
              ] else ...[
                Column(children: [
                  CircleAvatar(radius: 150, backgroundImage: AssetImage("assets/images/no_photo.jpg"),),
                  ElevatedButton(
                    onPressed: () async {
                      result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        if (!kIsWeb) {
                          file = File(result!.files.single.path!);
                          /*FirebaseFirestore.instance
                          .collection('avatar')
                          .add(imagePath);*/
                        }
                        setState(() {
                          imagePath = "${result!.files.single.path}";
                        });
                      }
                    },
                    child: const Text('Выбрать фото'),
                  ),
                ],)
              ]
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 30)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Добро пожаловать, Иван!',
                style: TextStyle(
                    fontFamily: 'PTSans',
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 30)),
          Container(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/todo');
                },
                child: Text(
                  'Перейти к списку дел',
                  style: TextStyle(color: Color(0xff0051D3)),
                )
            ),
          ),
        ],
      ),
    );
  }
}
