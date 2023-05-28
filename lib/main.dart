import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podoco_plant_diesease_classifier/classifier/classifier.dart';
import 'package:podoco_plant_diesease_classifier/components/Header.dart';
import 'package:podoco_plant_diesease_classifier/components/ResultTextBox.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

void main() {
  runApp(PodocoApp());
}

class PodocoApp extends StatefulWidget {
  @override
  _PodocoAppState createState() => _PodocoAppState();
}

class _PodocoAppState extends State<PodocoApp> {
  var _model;
  var _labels;
  final ImagePicker _imagePicker = ImagePicker();
  var _selectedImage;

  bool _resultStatus = false;
  late LabelScore _labelScore;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  void _loadModel() async {
    _labels = await PodocoClassifierModel.loadLabels();
    _model = await PodocoClassifierModel.createModel(_labels);
    
  }

  void _pickImage(ImageSource imageSource) async {
    final XFile? image = await _imagePicker.pickImage(source: imageSource);

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });

    final imageFile = File(image.path);
    _classifyImage(imageFile);
  }

  void _classifyImage(imageFile) async {
    var result = _model.classify(imageFile);

    final resultStatus =
        result.score >= 0.8 ? ResultStatus.found : ResultStatus.notFound;

    setState(() {
      _resultStatus = resultStatus;
      _labelScore = LabelScore(label: result.label,score:result.score);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.greenAccent,
        fontFamily: 'Georgia',
      ),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
              child: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Header(),
                    Container(
                        child: Column(
                          children: [
                      Center(child: Container(
                          height: 300,
                          width: 300,
                          child: _selectedImage != null
                              ? Image.file(_selectedImage, fit: BoxFit.cover)
                              : const Text(
                                  "Please select an image that contains plant"))),
                      Center(child: Container(
                        child: _selectedImage != null
                            ? _resultStatus
                                ? ResultTextBox(labelScore: _labelScore)
                                : const Text("Can't Classify")
                            : null,
                      ),)
                    ])),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.indigoAccent,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 20),
                          child: InkWell(
                              onTap: () {
                                _pickImage(ImageSource.camera);
                              },
                              child: const Center(child: Text("Take from Camera"))),
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.greenAccent,
                          padding: const EdgeInsets.all(20),
                          child: InkWell(
                              onTap: () {
                                _pickImage(ImageSource.gallery);
                              },
                              child: const Center(child: Text("Choose from Gallery"))),
                        ),
                      ],
                    ))
                  ]),
            )),
      ),
    );
  }
}
