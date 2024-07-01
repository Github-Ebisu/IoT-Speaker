import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../cloud_functions/auth_service.dart';
import '../../widgets/loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({super.key, required this.toggleView});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String email = "", password = "", name = "";
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController mailcontroller = new TextEditingController();

  final AuthService _authService = AuthService();
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;

  Future registration() async {
    if (password != null && namecontroller.text != "" && mailcontroller.text != "") {
      var errorMessage = await _authService.registerWithEmailAndPassword(email, password, name);
      setState(() {
        isLoading = false;
      });
      return errorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Register"),
              leading: IconButton(
                onPressed: () {
                  widget.toggleView(); // Access the funtion of widget
                },
                style: OutlinedButton.styleFrom(backgroundColor: Colors.transparent, side: BorderSide.none),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
              ),
              centerTitle: true,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
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
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                              decoration: BoxDecoration(color: Color(0xFFedf0f8), borderRadius: BorderRadius.circular(30)),
                              // Name
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Name';
                                  }
                                  return null;
                                },
                                controller: namecontroller,
                                decoration: InputDecoration(border: InputBorder.none, hintText: "Name", hintStyle: TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0)),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                              decoration: BoxDecoration(color: Color(0xFFedf0f8), borderRadius: BorderRadius.circular(30)),

                              // Email
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Email';
                                  }
                                  return null;
                                },
                                controller: mailcontroller,
                                decoration: InputDecoration(border: InputBorder.none, hintText: "Email", hintStyle: TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0)),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                              decoration: BoxDecoration(color: Color(0xFFedf0f8), borderRadius: BorderRadius.circular(30)),

                              // Pasword
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                controller: passwordcontroller,
                                decoration: InputDecoration(border: InputBorder.none, hintText: "Password", hintStyle: TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0)),
                                obscureText: true,
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            GestureDetector(
                              onTap: () {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    email = mailcontroller.text;
                                    name = namecontroller.text;
                                    password = passwordcontroller.text;
                                    isLoading = true;
                                  });
                                }
                                registration().then((errorMessage) {
                                  if (errorMessage is String) {
                                    Future.delayed(const Duration(seconds: 1), () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.orangeAccent,
                                          content: Text(
                                            errorMessage,
                                            style: const TextStyle(fontSize: 18.0),
                                          ),
                                        ),
                                      );
                                    });
                                  }
                                });
                              },
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
                                  decoration: BoxDecoration(color: Color(0xFF273671), borderRadius: BorderRadius.circular(30)),
                                  child: Center(
                                      child: Text(
                                    "Sign Up",
                                    style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w500),
                                  ))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
