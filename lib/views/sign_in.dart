import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/sharedPrefrences.dart';
import 'package:chatapp/views/HomeScreen.dart';
import 'package:chatapp/views/signUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/FlutterToast.dart';

class signInScreen extends StatefulWidget {
  const signInScreen({Key? key}) : super(key: key);

  @override
  State<signInScreen> createState() => _signInScreenState();
}

class _signInScreenState extends State<signInScreen> {
  String email = "", password = "", name = "", pic = "", username = "", id = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  GlobalKey<FormState> formKeyforSignIn = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;

  void login() async {
    try {
      await _auth
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((value) {
        DatabaseMethods().getUser(emailController.text).listen((event) {
          // Check if there's any data returned
          if (event.snapshot.value != null) {
            var userData = event.snapshot.value.values.first;
            name = userData["name"];
            username = userData["username"];
            id = event.snapshot.key!;
            pic = userData["photo"];
            sharedPrefrenceHelper().saveDisplayName(name);
            sharedPrefrenceHelper().saveUserName(username);
            sharedPrefrenceHelper().saveUserEmail(emailController.text);
            sharedPrefrenceHelper().saveUserId(id);
            sharedPrefrenceHelper().saveUserPic(pic);

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
            Utils().toastMessage('Login Successful');
          } else {
            Utils().toastMessage('User not found');
          }
        });
      });
    } on FirebaseAuthException catch (e) {
      Utils().toastMessage(e.message!);
    }
  }

  // Rest of the code...

  void dispose() {
    // TODO: implement dispose
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
                      'Sign In',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Login to BidBazaar',
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
                          height: MediaQuery.of(context).size.height / 2,
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
                            key: formKeyforSignIn,
                            children: [
                              Form(
                                key: formKeyforSignIn, // Add key here
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          hintText: 'Email',
                                          prefixIcon: Icon(Icons.email),
                                          border: InputBorder.none,
                                        ),
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
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                          hintText: 'Password',
                                          prefixIcon: Icon(Icons.lock),
                                          border: InputBorder.none,
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please enter password"; // Fix error message
                                          }
                                          return null;
                                        },
                                        obscureText: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  "Forgot Pssword",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              InkWell(
                                onTap: () {
                                  if (formKeyforSignIn.currentState!
                                      .validate()) {
                                    login();
                                  }
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
                                      "Sign In",
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
                      "Don't have an account?",
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
                                builder: (context) => signUpScreen()));
                      },
                      child: Text(
                        "Sign Up",
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
