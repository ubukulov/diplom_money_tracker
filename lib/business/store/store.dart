import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Store extends ChangeNotifier{
  DateTime now = DateTime.now();
  DateTime selectedDate = DateTime.now();

  String avatarUrl = '';

  void changeSelectedDate(DateTime newDate) {
    selectedDate = newDate;
    notifyListeners();
  }

  String getMonthName() {
    String month = DateFormat('MMMM', 'ru').format(now);
    return month[0].toUpperCase() + month.substring(1);
  }

  void changeAvatarUrl(String imgUrl){
    avatarUrl = imgUrl;
    notifyListeners();
  }

  String getAvatarUrl() {
    return avatarUrl;
  }
}