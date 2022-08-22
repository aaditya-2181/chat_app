import 'package:chat_app/models/ui_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/complete_profile_page.dart';
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
      UIHelper.showAlertDailog(
          context, "incomplete data", "Please fill all tha data!");
    } else if (pass != cpass) {
      UIHelper.showAlertDailog(context, "Password incorrect",
          "The password you enterd do not match");
    } else {
      signUp(email, pass);
    }
  }

// End Controller and Variables

// Sign up function starting
  void signUp(String email, String pass) async {
    // show Loading dailog
    UIHelper.showLoadingDailog(context, "Creating new account");

    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (ex) {
      // remove the loading dailog
      Navigator.pop(context);

      // show the alert dailog
      UIHelper.showAlertDailog(context, "An error occured", ex.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
          uid: uid, email: email, userName: "", profilePic: "", password: pass);

// this line of code is for created new user
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        //  print("The new user created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
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
                  height: 16,
                ),
                TextField(
                  controller: cPassController,
                  decoration:
                      const InputDecoration(labelText: "confirm password"),
                ),
                const SizedBox(
                  height: 24,
                ),

                // Sign In Button is starting
                CupertinoButton(
                  onPressed: () {
                    checkValue();
                  },
                  color: Colors.blueAccent,
                  child: const Text("Sign In"),
                )
                // Sign In Button is Ending
              ],
            ),
          ),
        ),
      )),

      // Navigetion Bar is Starting
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "You already  have an acount?",
            style: TextStyle(fontSize: 18),
          ),
          CupertinoButton(
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),

      // Navigetion Bar is Ending
    );
  }
}
