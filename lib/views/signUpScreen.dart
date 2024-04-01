import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/sharedPrefrences.dart';
import 'package:chatapp/utils/FlutterToast.dart';
import 'package:chatapp/views/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class signUpScreen extends StatefulWidget {
  const signUpScreen({super.key});

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {
  String email = "", password = "", name = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  GlobalKey<FormState> formKeyforSignIn = GlobalKey<FormState>();

  void signUp() async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.toString(),
        password: passwordController.text.toString(),
      );
      String id = randomAlphaNumeric(10);
      String user = emailController.text.replaceAll("@gmail.com", "");
      String updateUsername = user.replaceFirst(user[0], user[0].toUpperCase());
      String firstletter = user.substring(0, 1).toUpperCase();
      Map<String, dynamic> userInfoMap = {
        "email": emailController.text.toString(),
        "password": passwordController.text.toString(),
        "name": nameController.text.toString(),
        "username": updateUsername.toUpperCase(),
        "searchKey": firstletter,
        "photo":
            "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fprofile-image&psig=AOvVaw0A5wb49XEbpbQKpMJFU1tw&ust=1710049893171000&source=images&cd=vfe&opi=89978449&ved=0CBMQjRxqFwoTCPjxrLe-5oQDFQAAAAAdAAAAABAE",
        "id": id,
      };
      await DatabaseMethods().addUserInfo(userInfoMap, id);
      await sharedPrefrenceHelper().saveUserId(id);
      await sharedPrefrenceHelper()
          .saveUserName(nameController.text.toString());
      await sharedPrefrenceHelper()
          .saveUserEmail(emailController.text.toString());
      await sharedPrefrenceHelper()
          .saveDisplayName(emailController.text.replaceAll("@gmail.com", ""));
      await sharedPrefrenceHelper().saveUserPic(
          "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fprofile-image&psig=AOvVaw0A5wb49XEbpbQKpMJFU1tw&ust=1710049893171000&source=images&cd=vfe&opi=89978449&ved=0CBMQjRxqFwoTCPjxrLe-5oQDFQAAAAAdAAAAABAE");
      Utils().toastMessage("Sign-Up Successful");
    } catch (error) {
      Utils().toastMessage(error.toString());
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 4.1,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange,
                  Color(0xFFFFAA2C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(300, 105.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35),
            child: Column(
              children: [
                Center(
                    child: Column(
                  children: [
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Sign up to BidBazaar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 226, 211, 153),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        elevation: 5,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 50, horizontal: 20),
                          height: MediaQuery.of(context).size.height / 1.5,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            // boxShadow: const [
                            //   BoxShadow(
                            //     color: Colors.black,
                            //     blurRadius: 1.7,
                            //     offset: Offset(0, 0.9),
                            //   ),
                            // ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1, color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                      hintText: 'Name',
                                      prefixIcon: Icon(Icons.person),
                                      border: InputBorder.none),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Form(
                                  key: formKeyforSignIn,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.grey.shade300),
                                        ),
                                        child: TextFormField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                              hintText: 'Email',
                                              prefixIcon: Icon(Icons.email),
                                              border: InputBorder.none),
                                          obscureText: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Please enter email";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.grey.shade300),
                                        ),
                                        child: TextFormField(
                                          controller: passwordController,
                                          decoration: InputDecoration(
                                              hintText: 'Password',
                                              prefixIcon: Icon(Icons.lock),
                                              border: InputBorder.none),
                                          obscureText: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Please enter email";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1, color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                      hintText: 'Confirm Password',
                                      prefixIcon: Icon(Icons.lock),
                                      border: InputBorder.none),
                                  obscureText: true,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              InkWell(
                                onTap: () {
                                  if (formKeyforSignIn.currentState!
                                      .validate()) {
                                    setState(() {
                                      email = emailController.text.toString();
                                      password =
                                          passwordController.text.toString();
                                      name = nameController.text.toString();
                                    });
                                  }
                                  signUp();
                                },
                                child: Container(
                                  width: 150,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => signInScreen()));
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
