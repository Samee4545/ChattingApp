import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/sharedPrefrences.dart';
import 'package:chatapp/utils/FlutterToast.dart';
import 'package:chatapp/views/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChattingScreen extends StatefulWidget {
  String name, profileUrl, username;
  ChattingScreen(
      {required this.name, required this.profileUrl, required this.username});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  TextEditingController messageController = new TextEditingController();
  String? myName, myProfileUrl, myUsername, myEmail, messageId, chatRoomId;
  Stream? messageStream;

  Future<void> getTheSharedPref() async {
    myName = await sharedPrefrenceHelper().getDisplayName();
    myProfileUrl = await sharedPrefrenceHelper().getUserPic();
    myUsername = await sharedPrefrenceHelper().getUserName();
    myEmail = await sharedPrefrenceHelper().getUserEmail();
    chatRoomId = getChatRoomIDbyUser(myUsername!, widget.username);
    setState(() {});
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight:
                    sendByMe ? Radius.circular(0) : Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: sendByMe ? Radius.circular(0) : Radius.circular(24),
              ),
              color: sendByMe
                  ? const Color.fromARGB(255, 221, 229, 229)
                  : const Color.fromARGB(255, 211, 228, 243),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId!);
    print("===============================");
    print(messageStream);
    setState(() {});
  }

  // Widget chatMessages() {
  //   return StreamBuilder(
  //     stream: messageStream,
  //     builder: (context, AsyncSnapshot snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       }
  //       if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       }
  //       if (!snapshot.hasData || snapshot.data == null) {
  //         return Text('No data');
  //       }
  //       return ListView.builder(
  //         padding: EdgeInsets.only(bottom: 90, top: 130),
  //         reverse: true,
  //         itemCount: snapshot.data.length,
  //         itemBuilder: (context, index) {
  //           DocumentSnapshot ds = snapshot.data[index];
  //           // DocumentSnapshot ds = snapshot.data.docs[index];
  //           return chatMessageTile(ds["message"], myUsername == ds["sendBy"]);
  //         },
  //       );
  //     },
  //   );
  // }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Text('No data');
        }
        if (snapshot.data is List && snapshot.data.isNotEmpty) {
          print("=====================================================SizeBox");
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 90, top: 130),
            reverse: true,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              // Handle null items
              if (snapshot.data[index] == null) {
                print(
                    "=====================================================SizeBox");
                return SizedBox(); // Or any other placeholder widget
              }
              DocumentSnapshot ds = snapshot.data[index];
              return chatMessageTile(ds["message"], myUsername == ds["sendBy"]);
            },
          );
        } else {
          return Text('No messages available');
        }
      },
    );
  }

  onTheLoad() async {
    await getTheSharedPref();
    await getAndSetMessages();
    setState(() {});
  }

  void addMessage(bool sendClicked) {
    print('myName: $myName');
    print('myusername: $myUsername');
    print('myProfileUrl: $myProfileUrl');
    print('chatRoomId: $chatRoomId');
    if (myName != null && myProfileUrl != null && chatRoomId != null) {
      if (messageController.text != "") {
        String message = messageController.text;
        Map<String, dynamic> chatMessageMap = {
          "message": message,
          "sendBy": myName!,
          "profileUrl": myProfileUrl!,
          "time": DateTime.now().millisecondsSinceEpoch,
        };

        messageId ??= DateTime.now().millisecondsSinceEpoch.toString();

        // Add try-catch block to handle potential exceptions
        try {
          DatabaseMethods()
              .addMessage(chatRoomId!, messageId!, chatMessageMap)
              .then((value) {
            if (sendClicked) {
              // Clear the text field
              messageController.clear();
              Utils().toastMessage("Message sent");
              Map<String, dynamic> lastMessageInfoMap = {
                "lastMessage": message,
                "lastMessageSendBy": myName!,
                "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
              };
              DatabaseMethods()
                  .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
              if (sendClicked) {
                messageId = null;
              }
            }
          });
        } catch (e) {
          Utils().toastMessage('Error sending message: $e');
        }
      }
    } else {
      Utils().toastMessage('Missing required data');
    }
  }

  getChatRoomIDbyUser(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    messageStream = Stream.empty();
    onTheLoad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.orange,
        body: Container(
          margin: EdgeInsets.only(
            top: 15,
          ),
          child: Stack(
            children: [
              chatMessages(),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.1382,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, bottom: 25),
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 1.3,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: TextFormField(
                                  controller: messageController,
                                  decoration: InputDecoration(
                                    hintText: "Type a message",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                addMessage(true);
                                Utils().toastMessage("Message sent");
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
