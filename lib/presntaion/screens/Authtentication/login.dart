import 'package:flutter/material.dart';
import 'package:map_graduation_project/controller/SQLite/sqlite.dart';
import 'package:map_graduation_project/controller/model/users.dart';
import 'package:map_graduation_project/presntaion/screens/Authtentication/signup.dart';
import 'package:map_graduation_project/presntaion/screens/search/search_screen.dart';
import 'package:map_graduation_project/presntaion/widget/custom_text_filed_widget.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //We need two text editing controller

  //TextEditing controller to control the text when we enter into it
  final username = TextEditingController();
  final password = TextEditingController();

  //A bool variable for show and hide password
  bool isVisible = false;

  //Here is our bool variable
  bool isLoginTrue = false;

  final db = DatabaseHelper();

  //Now we should call this function in login button
  login() async {
    var response = await db
        .login(Users(usrName: username.text, usrPassword: password.text));
    if (response == true) {
      //If login is correct, then goto notes
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) =>  const SearchScreen()));
    } else {
      //If not, true the bool value to show error message
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  //We have to create global key for our form
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            //We put all our textfield to a form to be controlled and not allow as empty
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  //Username field

                  //Before we show the image, after we copied the image we need to define the location in pubspec.yaml
                  Image.asset(
                    "assets/images/station.png",
                  ),
                  const SizedBox(height: 30),
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

                  //Password field
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

                  const SizedBox(height: 20),
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
                            login();

                            //Now we have a response from our sqlite method
                            //We are going to create a user
                          }
                        },
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  //Sign up button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                          onPressed: () {
                            //Navigate to sign up
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUp()));
                          },
                          child: const Text("SIGN UP"))
                    ],
                  ),

                  // We will disable this message in default, when user and pass is incorrect we will trigger this message to user
                  isLoginTrue
                      ? const Text(
                          "username or password is incorrect",
                          style: TextStyle(color: Colors.red),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
