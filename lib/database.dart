import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Database {
  CollectionReference _birthdays =
      FirebaseFirestore.instance.collection('birthdays');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  get context => null; //important
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        context: this.context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                ),
                TextFormField(
                  controller: _birthdayController,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final String? birthday = _birthdayController.text;
                    await _birthdays.add({"name": name, "birthday": birthday});
                  },
                  child: Text('Add'),
                )
              ],
            ),
          );
        });
  }
}
