import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podoco_plant_diesease_classifier/classifier/classifier.dart';
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

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  void _loadModel() async{
    _model = await PodocoClassifierModel.createModel();
    _labels = await PodocoClassifierModel.loadLabels();
  }

  void _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);

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
    final normalizeOp = NormalizeOp(127.5, 127.5);

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

  _postProcessOutput(TensorBuffer outputBuffer){
    final probabilityProcessor = TensorProcessorBuilder().build();
    probabilityProcessor.process(outputBuffer);
    final results = TensorLabel.fromList(_labels, outputBuffer);

    final labelList = [];
    results.getMapWithFloatValue().forEach((key, value){
      print("Label $key - Score $value");
    });
  }

  void _classifyImage(imageFile) async {
    final inputTensorImage = await _preProcessInput(imageFile);

    final outputBuffer = TensorBuffer.createFixedSize(_model.outputShape, _model.outputType);
    _model.interpreter.run(inputTensorImage.buffer, outputBuffer.buffer);

    print('OutputBuffer: ${outputBuffer.getDoubleList()}');

    _postProcessOutput(outputBuffer);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.greenAccent,
        fontFamily: 'Georgia',
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Podoco - Plant Disease Classifier"),
          ),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    height: 300,
                    width: 300,
                    child: _selectedImage != null
                        ? Image.file(_selectedImage, fit: BoxFit.cover)
                        : const Text(
                            "Please select an image that contains plant")),
                Container(
                  child: ElevatedButton(
                      onPressed: () {
                        _pickImage();
                      },
                      child: const Text("Choose Image From Gallery")),
                )
              ])),
    );
  }
}
