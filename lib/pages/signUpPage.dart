import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/completeProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
// All Controller and Variables are Define in here
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController cPassController = TextEditingController();

  void checkValue() {
    String email = emailController.text.trim();
    String pass = passController.text.trim();
    String cpass = cPassController.text.trim();
    if (email == "" || pass == "" || cpass == "") {
      print("All filds are requirds");
    } else if (pass != cpass) {
      print("Password dose not match");
    } else {
      signUp(email, pass);
    }
  }

// End Controller and Variables

// Sign up function starting
  void signUp(String email, String pass) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, userName: "", profilePic: "");

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("The new user created");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CompleteProfilePage(
              userModel: newUser, firebaseUser: credential!.user!);
        }));
      });
    }
  }

// Sign up function ending

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
                  height: 16,
                ),
                TextField(
                  controller: cPassController,
                  decoration: InputDecoration(labelText: "confirm password"),
                ),
                SizedBox(
                  height: 24,
                ),

                // Sign In Button is starting
                CupertinoButton(
                  onPressed: () {
                    checkValue();
                  },
                  child: Text("Sign In"),
                  color: Colors.blueAccent,
                )
                // Sign In Button is Ending
              ],
            ),
          ),
        ),
      )),

      // Navigetion Bar is Starting
      bottomNavigationBar: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "You already  have an acount?",
            style: TextStyle(fontSize: 18),
          ),
          CupertinoButton(
              child: Text(
                "Login",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      )),

      // Navigetion Bar is Ending
    );
  }
}
