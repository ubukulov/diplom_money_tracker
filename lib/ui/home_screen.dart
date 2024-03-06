import 'package:diplom_money_tracker/business/models/category.dart';
import 'package:diplom_money_tracker/config/vars.dart';
import 'package:diplom_money_tracker/ui/expense_screen.dart';
import 'package:diplom_money_tracker/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../business/store/store.dart';
import 'package:diplom_money_tracker/business/models/tab.dart';

class HomeScreen extends StatefulWidget{
  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final store = Store();
  final List<Tabs> _tabs = [
    Tabs(title: "Расходы", icon: Icon(Icons.credit_card)),
    Tabs(title: "Профиль", icon: Icon(Icons.account_circle_rounded))
  ];

  late Tabs _myHandler ;
  late TabController _controller ;

  final TextEditingController _categoryNameController  = TextEditingController();
  final TextEditingController _categoryColorController = TextEditingController();

  late CollectionReference<Category> _categoryList;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _myHandler = _tabs[0];
    _controller.addListener(_handleSelected);
  }

  void _handleSelected() {
    setState(() {
      _myHandler= _tabs[_controller.index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: (_controller.index == 0) ? Text('${store.getMonthName()} ${store.now.year}') : Text('Профиль'),
              backgroundColor: mainColor,
              centerTitle: true,
              actions: (_controller.index == 0) ? [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Добавить категорию', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                    labelText: 'Название'
                                ),
                                controller: _categoryNameController,
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                    labelText: 'Цвет'
                                ),
                                maxLength: 6,
                                controller: _categoryColorController,
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 10.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _categoryList.add(
                                        Category(name: _categoryNameController.text.trim(), color: _categoryColorController.text)
                                    );
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
                  },
                )
              ] : [],
            ),
            body: TabBarView(
              controller: _controller,
              children: [
                ExpenseScreen(),
                ProfileScreen()
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 1.0,
                          color: Colors.grey
                      )
                  )
              ),
              child: TabBar(
                controller: _controller,
                tabs: [
                  Tab(text: _tabs[0].title, icon: _tabs[0].icon,),
                  Tab(text: _tabs[1].title, icon: _tabs[1].icon)
                ],
                labelColor: mainColor,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: mainColor,
              ),
            )
        )
    );
  }
}