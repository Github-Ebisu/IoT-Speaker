import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../cloud_functions/auth_service.dart';
import '../../widgets/loading.dart';

class Login extends StatefulWidget {
  final Function toggleView;

  const Login({super.key, required this.toggleView});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService();

  String email = "", password = "";
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;

  Future userLogin() async {
    var errorMessage = await _authService.signInWithEmailAndPassword(email: email, password: password);
    setState(() {
      isLoading = false;
    });

    return errorMessage;
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 400,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 30,
                            width: 80,
                            height: 200,
                            child: FadeInUp(
                                duration: const Duration(seconds: 1),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/light-1.png'),
                                    ),
                                  ),
                                )),
                          ),
                          Positioned(
                            left: 140,
                            width: 80,
                            height: 150,
                            child: FadeInUp(
                                duration: Duration(milliseconds: 1200),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/light-2.png'),
                                    ),
                                  ),
                                )),
                          ),
                          Positioned(
                            right: 40,
                            top: 40,
                            width: 80,
                            height: 150,
                            child: FadeInUp(
                                duration: const Duration(milliseconds: 1300),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/clock.png'),
                                    ),
                                  ),
                                )),
                          ),
                          Positioned(
                            child: FadeInUp(
                                duration: Duration(milliseconds: 1600),
                                child: Container(
                                  margin: EdgeInsets.only(top: 50),
                                  child: const Center(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          children: <Widget>[
                            FadeInUp(
                                duration: Duration(milliseconds: 1800),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Color.fromRGBO(143, 148, 251, 1)),
                                      boxShadow: const [BoxShadow(color: Color.fromRGBO(143, 148, 251, .2), blurRadius: 20.0, offset: Offset(0, 10))]),

                                  // Email & Password
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: const BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Color.fromRGBO(143, 148, 251, 1))),
                                        ),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please Enter E-mail';
                                            }
                                            return null;
                                          },
                                          controller: mailcontroller,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Email ",
                                            hintStyle: TextStyle(color: Colors.grey[700]),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please Enter Password';
                                            }
                                            return null;
                                          },
                                          controller: passwordcontroller,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Password",
                                            hintStyle: TextStyle(color: Colors.grey[700]),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )),

                            // Button Forgot password
                            const SizedBox(height: 15),
                            FadeInUp(
                                duration: const Duration(milliseconds: 2000),
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                                )),

                            // GestureDetector Login
                            const SizedBox(height: 40),
                            FadeInUp(
                              duration: Duration(milliseconds: 1900),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromRGBO(143, 148, 251, 1),
                                      Color.fromRGBO(143, 148, 251, .6),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_formkey.currentState!.validate()) {
                                        setState(() {
                                          email = mailcontroller.text;
                                          password = passwordcontroller.text;
                                          isLoading = true;
                                        });
                                        userLogin().then((errorMessage) {
                                          if (errorMessage is String) {
                                            Future.delayed(const Duration(seconds: 3), () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.purple,
                                                  content: Text(
                                                    errorMessage,
                                                    style: const TextStyle(fontSize: 18.0),
                                                  ),
                                                ),
                                              );
                                            });
                                          }
                                        });
                                      }
                                    },
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // GestureDetector register
                            const SizedBox(height: 40),
                            FadeInUp(
                                duration: Duration(milliseconds: 2000),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.toggleView();
                                    },
                                    child: const Text(
                                      "Create an account",
                                      style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
