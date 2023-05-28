import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

List list = ["English", "မြန်မာ"];

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _dropdownValue = list.first;
  final _url = "https://github.com/MinSiThu/Podoco";

  Future<void> _launchUrl() async {
  if (!await launch(
    _url,
    forceWebView: false,
    )) {
    throw Exception('Could not launch $_url');
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("About App"),
          backgroundColor: Colors.green,
          actions: [
            DropdownButton(
                value: _dropdownValue,
                items: list.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _dropdownValue = value!;
                  });

                  if(value == "မြန်မာ"){
                    Get.updateLocale(const Locale("my","MM"));
                  }else{
                    Get.updateLocale(const Locale("en","US"));
                  }
                })
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Text("about".tr),
            ),
            Container(child: TextButton(child: Text('Go to repository'),onPressed: (){
              _launchUrl();
            },),)
          ],
        ),
      ),
    );
  }
}
