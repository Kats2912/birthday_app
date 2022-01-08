import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CollectionReference _birthdays =
      FirebaseFirestore.instance.collection('birthdays');
  TextEditingController _nameController = TextEditingController();
  DateTime? _dateTime;
  final _formkey = GlobalKey<FormState>();
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        backgroundColor: Colors.black,
        context: this.context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      // labelText: 'Name',
                      hintText: 'Enter your name!',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green))),
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your name';
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  height: 50,
                  width: 200,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      _dateTime == null
                          ? 'Enter your DOB'
                          : DateFormat.yMMMd().format(_dateTime!),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      fixedSize: MaterialStateProperty.all(Size(400, 35)),
                    ),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1960),
                              lastDate: DateTime(2070))
                          .then((value) {
                        setState(() {
                          _dateTime = value!;
                        });
                      });
                    },
                    child: Text('Pick a date')),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    fixedSize: MaterialStateProperty.all(Size(400, 35)),
                  ),
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final String? birthday = _dateTime.toString();
                    if (_dateTime == null && _nameController.text == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please choose Birthdate!'),
                      ));
                    } else if (_nameController.text == null &&
                        _dateTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please enter your name')));
                    } else if (_nameController.text == null &&
                        _dateTime == null)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please fill required details!')));
                    else {
                      await _birthdays
                          .add({"name": name, "birthday": birthday});
                      Navigator.of(context).pop();
                      setState(() {
                        _nameController.text = ' ';
                        _dateTime = null;
                      });
                    }
                  },
                  child: Text('Add'),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: _birthdays.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

                return Card(
                  child: ListTile(
                      //leading: Text(documentSnapshot[index].toString()),
                      title: Text(documentSnapshot['name']),
                      subtitle: Text(documentSnapshot['birthday']),
                      trailing: IconButton(
                        onPressed: () async {
                          await _birthdays.doc(documentSnapshot.id).delete();
                        },
                        icon: Icon(Icons.delete),
                      )),
                );
              },
            );
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: Icon(Icons.add),
      ),
    );
  }
}
