import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'chat_screen.dart';
//import auth firebase -> create new user
import 'package:firebase_auth/firebase_auth.dart';
// import package for spinner
import 'package:modal_progress_hud/modal_progress_hud.dart';


class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  bool spinner = false;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                // email type
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  //Do something with the user input.

                  email = value;
                },
                decoration:
                kTextFieldDecoration.
                  copyWith(hintText:"Enter your Email"),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                // add hidden password
                obscureText: true,
                onChanged: (value) {

                  //Do something with the user input.
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText:"Enter your Password"),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(title:"Registration",colour:Colors.blueAccent,
                  onPressed:  () async {
                // set spinner => true
                    setState(() {
                      spinner = true;
                    });

                // create user -> email + password

                    try{
                  final newUser = await _auth.createUserWithEmailAndPassword(email: email,
                      password: password);
                  if(newUser != null){
                    //redirect new user to chat app
                    Navigator.pushNamed(context, ChatScreen.id);
                    // set spinner => true
                    setState(() {
                      spinner = false;
                    });
                  }
                } catch (e){
                  print("oliver, error in create new user by firebase: "+ e);
                }

              }),
            ],
          ),
        ),
      ),
    );
  }
}
