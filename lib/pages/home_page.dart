import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/chat_room_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const Home({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat App"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const LoginPage();
                }));
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      // recent chats start
      body: SafeArea(
          child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chatrooms")
            .where("participants.${widget.userModel.uid}", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
              return ListView.builder(
                itemCount: chatRoomSnapshot.docs.length,
                itemBuilder: (context, index) {
                  ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                      chatRoomSnapshot.docs[index].data()
                          as Map<String, dynamic>);
                  Map<String, dynamic> participents =
                      chatRoomModel.participants!;

                  List<String> participentsKeys = participents.keys.toList();

                  participentsKeys.remove(widget.userModel.uid);
                  return FutureBuilder(
                    future:
                        FirebaseHelper.getUserModelById(participentsKeys[0]),
                    builder: (context, userData) {
                      if (userData.connectionState == ConnectionState.done) {
                        if (userData.data != null) {
                          UserModel targetUser = userData.data as UserModel;
                          return ListTile(
                              // on tap chat list
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChatRoomPage(
                                      targetUser: targetUser,
                                      chatroom: chatRoomModel,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser);
                                }));
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    targetUser.profilePic.toString()),
                              ),
                              title: Text(targetUser.userName.toString()),
                              subtitle: (chatRoomModel.lastMassage.toString() !=
                                      "")
                                  ? Text(chatRoomModel.lastMassage.toString())
                                  : const Text(
                                      "Say hi to your new friend",
                                      style:
                                          TextStyle(color: Colors.blueAccent),
                                    ));
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                snapshot.hashCode.toString(),
              ));
            } else {
              return const Center(
                child: Text("no chats"),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      )),

      // recent chats start
      // Floating search button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
