import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/homePage.dart';
import 'package:chat_app/pages/signUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
// variable and function is starting

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  void checkValue() {
    String email = emailController.text.trim();
    String pass = passController.text.trim();

    if (email == "" || pass == "") {
      print("All filds are requird");
    } else {
      logIn(email, pass);
    }
  }

  // Login function start

  void logIn(String email, String pass) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      // Go to Home Page
      print("Login success");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return home(userModel: userModel, firebaseUser: credential!.user!);
      }));
    }
  }
  // Login function end

// variable and function is ending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          //controller: controller,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  "Chat App",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "email or username"),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "password"),
                ),
                SizedBox(
                  height: 24,
                ),
                CupertinoButton(
                  onPressed: () {
                    checkValue();
                  },
                  child: Text("Login"),
                  color: Colors.blueAccent,
                )
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "You don't have an acount?",
            style: TextStyle(fontSize: 18),
          ),
          CupertinoButton(
              child: Text(
                "Sign In",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SignInPage();
                }));
              })
        ],
      )),
    );
  }
}
