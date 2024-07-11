import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/sharedPrefrences.dart';
import 'package:chatapp/views/chatView.dart';
import 'package:chatapp/views/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  bool search = false;

  String? myName, myProfilePic, myUserName, myEmail;
  getMyDetails() async {
    myName = await sharedPrefrenceHelper().getDisplayName();
    myProfilePic = await sharedPrefrenceHelper().getUserPic();
    myUserName = await sharedPrefrenceHelper().getUserName();
    myEmail = await sharedPrefrenceHelper().getUserEmail();
    setState(() {});
  }

  onTheLoad() async {
    await getMyDetails();
    setState(() {});
  }

  void initState() {
    onTheLoad();
    super.initState();
  }

  @override
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

  var queryResultSet = [];
  var tempSearchStore = [];
  initialSearch(value) {
    if (value.isEmpty) {
      setState(() {
        search = false;
        tempSearchStore.clear();
      });
      return;
    }

    setState(() {
      search = true;
    });

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    DatabaseMethods().SearchByName(value).then((value) {
      if (value != null) {
        setState(() {
          tempSearchStore = value.values.toList();
        });
      } else {
        setState(() {
          tempSearchStore = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Container(
        margin: EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                search
                    ? Expanded(
                        child: TextField(
                          onChanged: (value) =>
                              initialSearch(value.toUpperCase()),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: Colors.black,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Text(
                          'Chat Up',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      search = !search;
                      tempSearchStore.clear();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            auth.signOut();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => signInScreen()),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.logout,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),

            // Conditional rendering based on the 'search' variable
            if (search)
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: tempSearchStore.length,
                    itemBuilder: (context, index) {
                      return buildResultCard(tempSearchStore[index]);
                    },
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildUserCard(
                              name: "Sameer",
                              message: "Hey! What are you doing?",
                              time: "4:32 PM",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      buildUserCard(
                        name: "Sameer",
                        message: "Hey! What are you doing?",
                        time: "4:32 PM",
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    if (data == null || data['searchKey'] == null) {
      return SizedBox(); // Return an empty SizedBox if data or searchKey is null
    }

    return GestureDetector(
      onTap: () async {
        search = false;
        setState(() {});
        var chatRoomId = getChatRoomIDbyUser(
          myUserName!,
          data['username'],
        );
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, data['username']]
        };

        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChattingScreen(
                      name: data['name'],
                      profileUrl: data['photo'],
                      username: data['username'],
                    )));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                data['name'] ??
                    '', // Use null-aware operators to handle null values
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                data['username'] ??
                    '', // Use null-aware operators to handle null values
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUserCard(
      {required String name, required String message, required String time}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                "assets/profilePic.jpg",
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 12),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
