import 'package:chat_app/models/ui_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/sign_up_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      UIHelper.showAlertDailog(
          context, "incomplete data", "Please fill all tha data!");
    } else {
      logIn(email, pass);
    }
  }

  // Login function start

  void logIn(String email, String pass) async {
    UIHelper.showLoadingDailog(context, "Loggin.....");
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (ex) {
      // Close the Loading Dailog page
      Navigator.pop(context);

      // show alert dalilogbox
      UIHelper.showAlertDailog(context, "An error occuerd", ex.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      // Go to Home Page
      // print("Login success");
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Home(userModel: userModel, firebaseUser: credential!.user!);
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
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Text(
                  "Chat App",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: emailController,
                  decoration:
                      const InputDecoration(labelText: "email or username"),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "password"),
                ),
                const SizedBox(
                  height: 24,
                ),
                CupertinoButton(
                  onPressed: () {
                    checkValue();
                  },
                  color: Colors.blueAccent,
                  child: const Text("Login"),
                )
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "You don't have an acount?",
            style: TextStyle(fontSize: 18),
          ),
          CupertinoButton(
              child: const Text(
                "Sign In",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const SignInPage();
                }));
              })
        ],
      ),
    );
  }
}
