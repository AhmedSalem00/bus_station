import 'package:flutter/material.dart';
import 'package:map_graduation_project/controller/SQLite/sqlite.dart';
import 'package:map_graduation_project/controller/model/users.dart';
import 'package:map_graduation_project/presntaion/screens/Authtentication/login.dart';
import 'package:map_graduation_project/presntaion/widget/custom_text_filed_widget.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  bool isVisibleConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      //SingleChildScrollView to have an scroll in the screen
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //We will copy the previous text-field we designed to avoid time consuming
                  const ListTile(
                    title: Text(
                      "Register New Account",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),

                  //As we assigned our controller to the textformfields
                  CustomTextFiled(
                    textEditingController: username,
                    labelText: 'user',
                    validatorFun: (value) {
                      if (value!.isEmpty) {
                        return "user is filed";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  CustomTextFiled(
                    obscureText: isVisible,
                    iconButton: IconButton(
                        onPressed: () {
                          //In here we will create a click to show and hide the password a toggle button
                          setState(() {
                            //toggle button
                            isVisible = !isVisible;
                          });
                        },
                        icon: Icon(isVisible
                            ? Icons.visibility
                            : Icons.visibility_off)),
                    textEditingController: password,
                    labelText: 'Password',
                    validatorFun: (value) {
                      if (value!.isEmpty) {
                        return "Password is filed";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),
                  CustomTextFiled(
                    iconButton: IconButton(
                        onPressed: () {
                          //In here we will create a click to show and hide the password a toggle button
                          setState(() {
                            //toggle button
                            isVisibleConfirm = !isVisibleConfirm;
                          });
                        },
                        icon: Icon(isVisibleConfirm
                            ? Icons.visibility_off
                            : Icons.visibility)
                    ),
                    textEditingController: confirmPassword,
                    labelText: 'Confirm Password',
                    obscureText: !isVisibleConfirm,
                    validatorFun: (value) {
                      if (value!.isEmpty) {
                        return "password is required";
                      } else if (password.text != confirmPassword.text) {
                        return "Passwords don't match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),
                  //Login button
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple),
                    child: TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            //Login method will be here

                            final db = DatabaseHelper();
                            db
                                .signup(Users(
                                    usrName: username.text,
                                    usrPassword: password.text))
                                .whenComplete(() {
                              //After success user creation go to login screen
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()));
                            });
                          }
                        },
                        child: const Text(
                          "SIGN UP",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),

                  //Sign up button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                          onPressed: () {
                            //Navigate to sign up
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()));
                          },
                          child: const Text("Login"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
