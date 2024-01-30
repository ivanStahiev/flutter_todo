import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic> toDoData = {};
  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  int idItem = 0;

  void initFireBase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  void noSyncFireBase() {
    Firebase.initializeApp();
  }

  @override
  void initState() {
    super.initState();
    initFireBase();
  }

  void _menuOpen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Меню'),
        ),
        body: Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
                child: Text('На главную')),
            Padding(padding: EdgeInsets.only(left: 15)),
            Text('Наше простое меню')
          ],
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffFF8D17),
        appBar: AppBar(
          backgroundColor: Color(0xff0051D3),
          title: Text(
            'Список задач',
            style: TextStyle(
                color: Colors.white, fontFamily: 'PTSans', fontSize: 24),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _menuOpen,
              icon: Icon(Icons.menu_outlined),
              color: Colors.white,
            )
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('items').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  idItem = snapshot.data!.docs.length;
              if (idItem == 0) return Center(child: Text('Задачи отсутствуют', style: TextStyle(fontSize: 28, color: Colors.white, shadows: [Shadow(color: Colors.black26,blurRadius: 5.0,offset: Offset(2,2))]),),);
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(snapshot.data!.docs[index].id),
                    child: Card(
                      child: ListTile(
                        title: Text(
                          snapshot.data!.docs[index].get('title'),
                          style: TextStyle(fontFamily: 'PTSans', fontSize: 18),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_sweep),
                          color: Color(0xffFF8D17),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('items')
                                .doc(snapshot.data!.docs[index].id)
                                .delete();
                          },
                        ),
                        onTap: () {
                          toDoData = {
                            'title': snapshot.data!.docs[index].get('title'),
                            'description':
                                snapshot.data!.docs[index].get('description'),
                            'date': snapshot.data!.docs[index].get('date')
                          };
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                    builder: (context, StateSetter setState) {
                                  return AlertDialog(
                                    title: Text('Изменить задачу'),
                                    content: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              onChanged: (String value) {
                                                toDoData['title'] = value;
                                              },
                                              onSaved: (value) {
                                                toDoData['title'] = snapshot
                                                    .data!.docs[index]
                                                    .get('title');
                                              },
                                              initialValue: snapshot
                                                  .data!.docs[index]
                                                  .get('title'),
                                              decoration: InputDecoration(
                                                  hintText: 'Название'),
                                              validator: (value) {
                                                if(value == null || value.isEmpty) {
                                                  return 'Введите название задачи';
                                                }
                                              },
                                            ),
                                            TextFormField(
                                              onChanged: (String value) {
                                                toDoData['description'] = value;
                                              },
                                              onSaved: (value) {
                                                toDoData['description'] =
                                                    snapshot.data!.docs[index]
                                                        .get('description');
                                              },
                                              initialValue: snapshot
                                                  .data!.docs[index]
                                                  .get('description'),
                                              decoration: InputDecoration(
                                                  hintText: 'Описание'),
                                              validator: (value) {
                                                if(value == null || value.isEmpty) {
                                                  return 'Укажите описание задачи';
                                                }
                                              },
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                final DateTime? dateTime =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            selectedDate,
                                                        firstDate:
                                                            DateTime(2000),
                                                        lastDate:
                                                            DateTime(3000));
                                                if (dateTime != null) {
                                                  setState(() {
                                                    selectedDate = dateTime;
                                                    toDoData['date'] =
                                                        "${dateTime.day}.${dateTime.month}.${dateTime.year}";
                                                  });
                                                }
                                              },
                                              child: Text("Указать дату выполнения"),
                                            ),
                                            toDoData['date'] != null ? Text("${toDoData['date']}") : Text('Задача не завершена'),
                                            TextFormField(
                                              onChanged: (String value) {
                                                toDoData['time_interval'] =
                                                    value;
                                              },
                                              decoration: InputDecoration(
                                                  hintText:
                                                      'Затраченное время'),
                                            ),
                                          ],
                                        )),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('items')
                                                .doc(snapshot
                                                    .data!.docs[index].id)
                                                .update(toDoData);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Сохранить')),
                                      ElevatedButton(
                                          onPressed: () {
                                            print(toDoData);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Закрыть'))
                                    ],
                                  );
                                });
                              });
                        },
                      ),
                    ),
                    onDismissed: (direction) {
                      FirebaseFirestore.instance
                          .collection('items')
                          .doc(snapshot.data!.docs[index].id)
                          .delete();
                    },
                  );
                },
              );
            }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff0051D3),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Добавить задачу'),
                    content: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (String value) {
                                toDoData['title'] = value;
                              },
                              decoration: InputDecoration(hintText: 'Название'),
                              validator: (value) {
                                if(value == null || value.isEmpty) {
                                  return 'Введите название задачи';
                                }
                              }
                            ),
                            TextFormField(
                              onChanged: (String value) {
                                toDoData['description'] = value;
                              },
                              decoration: InputDecoration(hintText: 'Описание'),
                              validator: (value) {
                                if(value == null || value.isEmpty) {
                                  return 'Укажите описание задачи';
                                }
                              },
                            ),
                            TextFormField(
                              onChanged: (String value) {
                                toDoData['date'] = value;
                              },
                              initialValue: "${selectedDate}",
                              decoration: InputDecoration(hintText: 'Дата завершения'),
                              onTap: () async {
                                final DateTime? dateTime = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(3000));
                                if (dateTime != null) {
                                  setState(() {
                                    selectedDate = dateTime;
                                    toDoData['date'] = "${dateTime.day}.${dateTime.month}.${dateTime.year}";
                                  });
                                }
                              },
                            ),
                            TextFormField(
                              onChanged: (String value) {
                                toDoData['time_interval'] = value;
                              },
                              decoration: InputDecoration(
                                  hintText: 'Время затраченное на выполнение'),
                            ),
                          ],
                        )),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            toDoData['number'] = ++idItem;
                            FirebaseFirestore.instance
                                .collection('items')
                                .add(toDoData);
                            Navigator.of(context).pop();
                          },
                          child: Text('Добавить'))
                    ],
                  );
                });
          },
          child: Icon(
            Icons.add_box,
            color: Colors.white,
          ),
        ));
  }
}
