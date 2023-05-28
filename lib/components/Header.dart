import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podoco_plant_diesease_classifier/pages/about_page.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text(
          "Podoco",
          style: TextStyle(
              color: Colors.green, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        TextButton(
            onPressed: () {
              Get.to(()=>AboutPage());
            },
            child: const Text(
              "About",
              style: TextStyle(color: Colors.green),
            ))
      ]),
    );
  }
}
