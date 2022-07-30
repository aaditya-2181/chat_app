import 'dart:developer';
import 'dart:io';

import 'package:chat_app/pages/homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/UserModel.dart';

class CompleteProfilePage extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  const CompleteProfilePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  // All Variables and functions are declare here
  File? imageFile;

  TextEditingController fullNameController = TextEditingController();
  void selectImage(ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      cropImage(pickedImage);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 30);
    File? file2 = File(croppedImage!.path);
    if (file2 != null) {
      setState(() {
        print("before assigning imageFile = $imageFile");
        imageFile = file2;
      });
      print("type of imagefile = ${imageFile.runtimeType}");
    }
  }

// Upload Picture options function
  void showProfilePicOption() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload profile picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo_album),
                  title: Text("Select from gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take a picture"),
                )
              ],
            ),
          );
        });
  }

  // Check Value of Profile Image and Fullname are empty or not
  void checkValue() {
    String fullname = fullNameController.text.trim();
    if (imageFile == null || fullname == "") {
      print("All Filds are Requirds");
    } else {
      log("Data Uploaded , checkValue()");
      uploadData();
    }
  }

  // End checkValue Funtion
  // uploadData function is starting
  void uploadData() async {
    log("Data Uploaded , UploadData");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilePic")
        .child(widget.userModel!.uid.toString())
        .putFile(imageFile!);
    log("Data Uploading...........");

    TaskSnapshot snapShot = await uploadTask;
    String? imageURL = await snapShot.ref.getDownloadURL();
    String? fullname = fullNameController.text.trim();

    widget.userModel!.profilePic = imageURL;
    widget.userModel!.userName = fullname;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel!.uid)
        .update(widget.userModel!.toMap())
        .then((value) {
      log("Data Uploaded");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return home(
            userModel: widget.userModel!, firebaseUser: widget.firebaseUser!);
      }));
    });
  }
  // uploadData function is ending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Profile"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),

            // Circuler profile pic
            CupertinoButton(
              onPressed: () {
                showProfilePicOption();
              },
              child: CircleAvatar(
                  radius: 80,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null)
                      ? Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null),
            ),
            SizedBox(
              height: 30,
            ),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                color: Colors.blueAccent,
                child: Text("Submit"),
                onPressed: () {
                  checkValue();
                })
          ],
        ),
      )),
    );
  }
}
