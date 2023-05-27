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
    _model = await PodocoClassifierModel.createModel();
    _labels = await PodocoClassifierModel.loadLabels();
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

  /*
   * tensorImage loads into inputTensor,
   * Image Preprocessor is built
   * inputTensor is preprocess
   * 
   */
  Future<TensorImage> _preProcessInput(var image) async {
    // # TensorImage is created and load Image
    final inputTensor = TensorImage.fromFile(image);
    //inputTensor.

    // # Crop Image to have square image
    final minLength = min(inputTensor.height, inputTensor.width);
    final cropOp = ResizeWithCropOrPadOp(minLength, minLength);

    // # Resize Image to model input shape
    final shapeLength = _model.inputShape[1];
    final resizeOp = ResizeOp(shapeLength, shapeLength, ResizeMethod.BILINEAR);

    // # Normalize Image, 127.5 is used cause model, to have -1 to 1
    final normalizeOp = NormalizeOp(224, 224);

    // # ImageProcessor and add Operations
    final imageProcessor = ImageProcessorBuilder()
        .add(cropOp)
        .add(resizeOp)
        .add(normalizeOp)
        .build();
    imageProcessor.process(inputTensor);

    // #6
    return inputTensor;
  }

  _postProcessOutput(TensorBuffer outputBuffer) {
    final probabilityProcessor = TensorProcessorBuilder().build();
    probabilityProcessor.process(outputBuffer);
    final results = TensorLabel.fromList(_labels, outputBuffer);

    final labelScoreList = [];
    results.getMapWithFloatValue().forEach((key, value) {
      labelScoreList.add(LabelScore(label: key, score: value));
      print("Label $key - Score $value");
    });

    labelScoreList.sort((item1, item2) => item2.score > item1.score ? 1 : -1);

    return labelScoreList
        .first; // because first item is always cabbage healthy # False True Result
  }

  void _classifyImage(imageFile) async {
    print("Preprocess");
    final inputTensorImage = await _preProcessInput(imageFile);

    print(inputTensorImage.tensorBuffer.shape);

    print("Pre Predict");
    final outputBuffer =
        TensorBuffer.createFixedSize(_model.outputShape, _model.outputType);
    _model.interpreter.run(inputTensorImage.buffer, outputBuffer.buffer);

    print("Pre PostProcess");
    print('OutputBuffer: ${outputBuffer.getDoubleList()}');

    var result = _postProcessOutput(outputBuffer);
    print(result.label);
    print(result.score);

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
