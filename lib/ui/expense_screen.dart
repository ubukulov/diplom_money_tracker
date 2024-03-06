
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../business/models/category.dart';
import '../business/routes/routes.dart';
import '../business/store/store.dart';
import '../config/vars.dart';

class ExpenseScreen extends StatefulWidget {

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {

  final store = Store();
  final TextEditingController _amountController        = TextEditingController();
  final storage = FirebaseStorage.instance;
  late CollectionReference<Category> _categoryList;

  @override
  void initState() {
    super.initState();
    _categoryList = FirebaseFirestore.instance.collection('categories').withConverter<Category>(
        fromFirestore: (snapshot, _) => Category.fromJson(snapshot.data()!),
        toFirestore: (category, _) => category.toJson()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
              color: Color.fromRGBO(208, 208, 208, 1),
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: FutureBuilder(
                future: _getCategoriesWithAmount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<PieChartSectionData> sections = [];

                    snapshot.data?.forEach((element) {
                      String title = element['name'];
                      Color color = Color(int.parse('0xff${element['color']}'));
                      sections.add(PieChartSectionData(
                          value: element['amount'],
                          color: color,
                          title: title,
                          radius: 80,
                          titleStyle: const TextStyle(color: Colors.white)
                      ));
                    });

                    return (sections.isNotEmpty)
                        ?
                    PieChart(
                      PieChartData(
                        sections: sections,
                      ),
                    )
                        :
                    Center(
                      child: Text('За ${store.getMonthName()} нет расходов'),
                    );
                  }
                },
              ),
            )
        ),
        Expanded(
          child: StreamBuilder<List<Category>>(
            stream: _categoryList.snapshots().map((e) => e.docs.map((e) => e.data()).toList()),
            builder: (context, snapshot) => ListView(
              padding: EdgeInsets.all(10.0),
              children: snapshot.hasData
                  ? snapshot.data!
                  .map((e) => Container(
                margin: EdgeInsets.only(bottom: 10.0),
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
                    onLongPress: () {
                      _removeCatDialog(context, e.name);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.black),
                    ),
                    title: GestureDetector(
                      child: Text(e.name),
                      onTap: () {
                        Routes.router.navigateTo(context, '/cat/${e.name}/${e.color}');
                      },
                    ),
                    subtitle: FutureBuilder(
                      future: calcExpense(e.name),
                      builder: (context, snapshot) {
                        if(snapshot.hasError) {
                          return Text('');
                        } else if(snapshot.hasData) {
                          var count = snapshot.data?.toInt();
                          return (count! > 0) ? Text('Всего: $count') : Text('Добавить расход');
                        } else {
                          return Text('');
                        }
                      },
                    ),
                    trailing: GestureDetector(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(int.parse('0xff${e.color}')),
                      ),
                      onTap: () {
                        _addExpenseDialog(context, e.name);
                      },
                    )
                ),
              )).toList()
                  : [],
            ),
          ),
        )
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _getCategoriesWithAmount() async {
    List<Map<String, dynamic>> items = [];
    QuerySnapshot<Map<String, dynamic>> categoriesReferences =  await FirebaseFirestore.instance.collection('categories').get();
    for(QueryDocumentSnapshot<Map<String, dynamic>> categoryDoc in categoriesReferences.docs) {
      QuerySnapshot<Map<String, dynamic>> categoryAmountReferences = await FirebaseFirestore.instance.collection('categories').doc(categoryDoc.reference.id).collection('expenses').get();

      double sumAmount = 0.0;
      for(QueryDocumentSnapshot<Map<String, dynamic>> categoryAmountDoc in categoryAmountReferences.docs) {
        if(categoryAmountDoc.data().containsKey('amount')) {
          sumAmount += categoryAmountDoc.data()['amount'];
        }
      }

      if(sumAmount > 0.0) {
        items.add({
          'name': categoryDoc.data()['name'],
          'color': categoryDoc.data()['color'],
          'amount': sumAmount
        });
      }
    }

    return items;
  }

  void _removeCatDialog(BuildContext context, String name) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: RichText(
              text: TextSpan(
                  text: 'Удалить категорию ',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0
                  ),
                  children: [
                    TextSpan(
                        text: '${name}?',
                        style: TextStyle(
                            color: mainColor
                        )
                    )
                  ]
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      deleteCatCollection(name);
                      Navigator.of(context).pop();
                      final snackBar = SnackBar(
                        content: Text('Категория: ${name} успешно удален!'),
                        action: SnackBarAction(
                          label: 'Закрыть',
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(mainColor),
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15.0)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ))
                    ),
                    child: const Text('Подтвердить'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
    );
  }

  void deleteCatCollection(String name) async {
    QuerySnapshot<Map<String, dynamic>> categoriesReferences = await FirebaseFirestore.instance.collection('categories').get();

    for(QueryDocumentSnapshot<Map<String, dynamic>> catDoc in categoriesReferences.docs) {
      if(catDoc.data()['name'] == name) {
        catDoc.reference.delete();
      }
    }
  }

  void _addExpenseDialog(BuildContext context, String name){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Добавить расход', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
              TextButton(
                // child: Text('${DateFormat('dd.MM.yyyy', 'ru').format(store.selectedDate).toString()}'),
                child: Consumer<Store>(
                  builder: (context, store, child) {
                    return Text(DateFormat('dd.MM.yyyy', 'ru').format(store.selectedDate).toString());
                  },
                ),
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: store.selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((dt) {
                    store.changeSelectedDate(dt!);
                  });
                },
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                    labelText: 'Введите сумму'
                ),
                controller: _amountController,
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    addExpense(name);
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(mainColor),
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15.0)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)
                      ))
                  ),
                  child: const Text('Добавить'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Отмена', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }

  void addExpense(String name) async {
    QuerySnapshot<Map<String, dynamic>> document = await FirebaseFirestore.instance.collection('categories').where("name", isEqualTo: name).get();
    DocumentReference documentRef = FirebaseFirestore.instance.collection('categories').doc(document.docs.first.id);

    Map<String, dynamic> item = {
      'amount': int.parse(_amountController.text),
      'date': store.selectedDate
    };

    documentRef.collection('expenses').add(item);
    _amountController.text = '';
  }

  Future<double> calcExpense(String name) async {
    double sum = 0.0;

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('categories').where("name", isEqualTo: name).get();
      QuerySnapshot<Map<String, dynamic>> amountsRef = await FirebaseFirestore.instance.collection('categories').doc(snapshot.docs.first.id).collection('expenses').get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in amountsRef.docs) {
        if(doc.data().containsKey('amount')) {
          sum += doc.data()['amount'];
        }
      }
    } catch (e) {
      print('Error calculating sum: $e');
    }
    return sum;
  }

}