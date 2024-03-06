import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CatDetailScreen extends StatelessWidget {

  static const routeName = '/cat';
  final String id;
  final String color;

  CatDetailScreen({required this.id, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse('0xff${color}')),
        title: Text(id),
      ),
      body: FutureBuilder(
        future: _getCategoriesAmounts(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView(
              children: snapshot.data!.map((e) =>
                Container(
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade300,
                            spreadRadius: 1,
                            blurRadius: 15
                        )
                      ]
                  ),
                  child: ListTile(
                    title: Text(e['amount'].toString()),
                    subtitle: Text(convertDate(e['date'])),
                    onLongPress: () {
                      deleteCollection(id, e['amount']);
                      final snackBar = SnackBar(
                        content: Text('Расход: ${e['amount']} успешно удален!'),
                        action: SnackBarAction(
                          label: 'Закрыть',
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  ),
                )
              ).toList(),
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getCategoriesAmounts(String name) async {

    QuerySnapshot<Map<String, dynamic>> categoriesReferences = await FirebaseFirestore.instance.collection('categories').where("name", isEqualTo: name).get();
    QuerySnapshot<Map<String, dynamic>> amountsRef = await FirebaseFirestore.instance.collection('categories').doc(categoriesReferences.docs.first.id).collection('expenses').get();

    List<Map<String, dynamic>> items = [];

    for(QueryDocumentSnapshot<Map<String, dynamic>> amountDoc in amountsRef.docs) {

      items.add({
        'amount': amountDoc.data()['amount'],
        'date': amountDoc.data()['date'],
      });

    }

    return items;
  }

  String convertDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMMM yyyy / h:mm', 'ru').format(dateTime);
  }

  void deleteCollection(String name, int amount) async {
    QuerySnapshot<Map<String, dynamic>> categoriesReferences = await FirebaseFirestore.instance.collection('categories').where("name", isEqualTo: name).get();
    QuerySnapshot<Map<String, dynamic>> amountsRef = await FirebaseFirestore.instance.collection('categories').doc(categoriesReferences.docs.first.id).collection('expenses').get();

    for(QueryDocumentSnapshot<Map<String, dynamic>> amountDoc in amountsRef.docs) {

      if(amountDoc.data()['amount'] == amount) {
        amountDoc.reference.delete();
      }

    }
  }
}