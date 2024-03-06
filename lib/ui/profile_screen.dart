import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:diplom_money_tracker/business/store/store.dart';
import '../business/routes/routes.dart';
import '../config/vars.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final store = Store();
  
  String imgPath = '';

  @override
  Widget build(BuildContext context) {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              (imgPath == '')
              ? GestureDetector(
                  onTap: () {
                    _openGallery();
                  },
                  child: CircleAvatar(
                    maxRadius: 40.0,
                    backgroundColor: Colors.grey.shade400,
                    child: (store.avatarUrl == '') ? Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 40.0) : Image.network(store.getAvatarUrl())
                  ),
                )
              :
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: Image.file(File(imgPath), width: 100.0),
                  ),
              (imgPath != '') ? TextButton(
                child: Text('Сохранить', style: TextStyle(color: mainColor)),
                onPressed: () {
                  uploadImage(imgPath);
                  setState(() {
                    imgPath = '';
                  });
                },
              ) : SizedBox(width: 1.0,)
            ],
          ),
          SizedBox(width: 20.0,),
          Column(
            children: [
              Text(userEmail!),
              Container(
                width: 150.0,
                margin: EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    _logout(context);
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(mainColor),
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15.0)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)
                      ))
                  ),
                  child: Text('Выйти'),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> _openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imgPath = pickedFile.path;
      });
    }
  }

  Future<String> uploadImage(String imagePath) async {
    File imageFile = File(imagePath);
    Reference storageReference = FirebaseStorage.instance.ref().child('images/${imageFile.path}');

    UploadTask uploadTask = storageReference.putFile(imageFile);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await storageReference.getDownloadURL();

    store.changeAvatarUrl(downloadUrl);

    return downloadUrl;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Routes.router.navigateTo(context, '/login');
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}