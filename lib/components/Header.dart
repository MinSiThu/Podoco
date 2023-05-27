import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text("Podoco",style: TextStyle(
          color: Colors.greenAccent,
          fontSize: 32,
          fontWeight: FontWeight.bold
        ),),
      ),
    );
  }
}