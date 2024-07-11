import 'dart:convert';

import 'package:chatapp/models/chatModel.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/sharedPrefrences.dart';
import 'package:chatapp/utils/FlutterToast.dart';
import 'package:chatapp/views/HomeScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChattingScreen extends StatefulWidget {
  String name, profileUrl, username;
  ChattingScreen(
      {required this.name, required this.profileUrl, required this.username});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  List<ChatModel> userChatListData = [];

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

  getAndSetMessages() async {
    try {
      List<ChatModel> products =
          await DatabaseMethods().getChatRoomMessages(chatRoomId!);
      if (mounted) {
        setState(() {
          userChatListData = products;
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // getAndSetMessages() async {
  //   Utils().toastMessage("products.length.toString()");
  //   try {
  //     List<ChatModel> products =
  //         await DatabaseMethods().getChatRoomMessages(chatRoomId!, "123");
  //     Utils().toastMessage(chatRoomId!);
  //     Utils().toastMessage(products.length.toString());
  //     if (mounted) {
  //       setState(() {
  //         productGridListData = products;
  //       });
  //     }
  //   } catch (e) {
  //     Utils().toastMessage(e.toString());
  //     print("Error fetching products: $e");
  //   }
  // }

  late DatabaseReference ref;

  @override
  void initState() {
    super.initState();
    onTheLoad();
    // ref = FirebaseDatabase.instance
    //     .ref('ChatRoom')
    //     .child(chatRoomId!)
    //     .child("Chats");
  }

  Widget chatMessageTile(String message, String sendByMe) {
    // Check if the message is a JSON string (indicating a custom offer)
    bool isCustomOffer = false;
    Map<String, dynamic>? customOfferData;

    try {
      // Try decoding the message
      customOfferData = jsonDecode(message);
      // If decoding is successful, it's a custom offer
      isCustomOffer = true;
    } catch (e) {
      // If decoding fails, it's a simple text message
      isCustomOffer = false;
    }

    return Row(
      mainAxisAlignment: (sendByMe != widget.name)
          ? MainAxisAlignment.end // Align other users' messages to the right
          : MainAxisAlignment.start, // Align current user's messages to the left
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              minWidth: 50, // Minimum width based on message size
              maxWidth: (isCustomOffer)
                  ? MediaQuery.of(context).size.width *
                  0.9 // Adjust width for custom offer messages (90% of screen width)
                  : MediaQuery.of(context).size.width / 1.5, // Maximum width as totalwidth/1.5
            ),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Set border radius to 10
              color: (sendByMe != widget.name)
                  ? const Color.fromARGB(255, 221, 229, 229)
                  : const Color.fromARGB(255, 211, 228, 243),
            ),
            child: isCustomOffer
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Custom Offer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Price: ${customOfferData!['price']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Description: ${customOfferData['description']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                if (sendByMe == widget.name) // Render button only for sender
                  ElevatedButton(
                    onPressed: () {
                      // Implement your logic for accepting the offer
                    },
                    child: Text('Accept Offer'),
                  ),
              ],
            )
                : Text(
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


  Widget chatMessages() {
    // Sort the list based on the time attribute in descending order
    userChatListData.sort((a, b) => b.time!.compareTo(a.time!));

    return Expanded(
      child: ListView.builder(
        reverse:
            true, // Reverse the list to display recent messages at the bottom
        itemCount: userChatListData.length,
        itemBuilder: (context, index) {
          return chatMessageTile(
            userChatListData[index].message!,
            userChatListData[index].sendBy.toString(),
          );
        },
      ),
    );
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
  //       if (snapshot.data is List && snapshot.data.isNotEmpty) {
  //         print("=====================================================SizeBox");
  //         return ListView.builder(
  //           padding: EdgeInsets.only(bottom: 90, top: 130),
  //           reverse: true,
  //           itemCount: snapshot.data.length,
  //           itemBuilder: (context, index) {
  //             // Handle null items
  //             if (snapshot.data[index] == null) {
  //               print(
  //                   "=====================================================SizeBox");
  //               return SizedBox(); // Or any other placeholder widget
  //             }
  //             DocumentSnapshot ds = snapshot.data[index];
  //             return chatMessageTile(ds["message"], myUsername == ds["sendBy"]);
  //           },
  //         );
  //       } else {
  //         return Text('No messages available');
  //       }
  //     },
  //   );
  // }

  onTheLoad() async {
    await getTheSharedPref();
    await getAndSetMessages();
    setState(() {});
  }

  void addMessage(bool sendClicked, {String? price, String? description}) {
    print('myName: $myName');
    print('myusername: $myUsername');
    print('myProfileUrl: $myProfileUrl');
    print('chatRoomId: $chatRoomId');
    print('Price: $price');
    print('Description: $description');
    if (myName != null && myProfileUrl != null && chatRoomId != null) {
      // Check if both price and description are empty
      if (price != null &&
          price.isNotEmpty &&
          description != null &&
          description.isNotEmpty) {
        // If both price and description are provided, create a custom offer message
        String message;
        Map<String, dynamic> customOffer = {
          'price': price,
          'description': description,
        };
        // Convert the custom offer to a JSON string
        message = jsonEncode(customOffer);

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
        Utils().toastMessage("Custom Offer Message: $message");
      } else {
        // If either price or description (or both) are empty, it's a simple message
        if (messageController.text.isNotEmpty) {
          // Use the simple message text
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
      }
    } else {
      Utils().toastMessage('Missing required data');
    }
  }

  String getChatRoomIDbyUser(String a, String b) {
    // Convert usernames to uppercase
    String userA = a.toUpperCase();
    String userB = b.toUpperCase();

    // Sort the uppercase usernames alphabetically
    List<String> users = [userA, userB];
    users.sort();

    // Concatenate the sorted uppercase usernames to form the chat room ID
    return "${users[0]}_${users[1]}";
  }

  @override
  // void initState() {
  //   messageStream = Stream.empty();
  //   super.initState();
  // }

  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height / 1.05,
          child: Stack(
            children: [
              Container(
                color: Colors.orange,
                height: 80,
                child: Padding(
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
                      // SizedBox(
                      //   width: 40,
                      // ),
                      Center(
                        child: Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      TextButton(
                          onPressed: () {
                            _showCustomOfferDialog(context);
                          },
                          child: Text("Custom Offer")),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 60,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(child: chatMessages()),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, bottom: 100),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.35,
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
                                    getAndSetMessages();
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
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }

  void _showCustomOfferDialog(BuildContext context) {
    TextEditingController priceController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Custom Offer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Enter Price'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Write Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Get the price and description entered by the user
                String price = priceController.text;
                String description = descriptionController.text;

                // Debug print to ensure the method is being called
                print('Sending custom offer message');

                // Call addMessage with custom offer details
                addMessage(true, price: price, description: description);
                getAndSetMessages();

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
