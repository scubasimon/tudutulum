import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tudu/consts/urls/URLConst.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeStateView();
  }


}

class HomeStateView extends State<HomeView> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: signOut,
      child: const Text("Sign-out"),
    );
  }

  void signOut() {
    FirebaseAuth.instance.signOut()
        .then((value) => Navigator.of(context).pushReplacementNamed(URLConsts.login));
  }
}