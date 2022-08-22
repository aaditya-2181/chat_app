import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

var uuid = const Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// Check user is already logged in or not
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Already Logged in
    UserModel? thisUserId =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserId != null) {
      runApp(MyAppLoggedIn(userModel: thisUserId, firebaseUser: currentUser));
    }
  } else {
    // Not Logged in
    runApp(const MyApp());
  }
}

// Not Logged in
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// Already Logged in
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
