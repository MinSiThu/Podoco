import 'dart:math';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

const labelFileName = 'assets/podoco_labels.txt';
const modelFileName = 'cropnet.tflite';

class PodocoClassifierModel {
  Interpreter interpreter; // to predict results
  List<int> inputShape; // shape of input data
  List<int> outputShape; // shape of output data

  TfLiteType inputType; // data type of input tensor
  TfLiteType outputType; // data type of output tensor

  var labels;

  PodocoClassifierModel({
    required this.interpreter,
    required this.inputShape,
    required this.outputShape,
    required this.inputType,
    required this.outputType,
    required this.labels,
  });

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
    final shapeLength = inputShape[1];
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
    final results = TensorLabel.fromList(labels, outputBuffer);

    final labelScoreList = [];
    results.getMapWithFloatValue().forEach((key, value) {
      labelScoreList.add(LabelScore(label: key, score: value));
      print("Label $key - Score $value");
    });

    labelScoreList.sort((item1, item2) => item2.score > item1.score ? 1 : -1);

    return labelScoreList
        .first; // because first item is always cabbage healthy # False True Result
  }

  classify(imageFile) async {
    final inputTensorImage = await _preProcessInput(imageFile);
    final outputBuffer = TensorBuffer.createFixedSize(outputShape, outputType);
    interpreter.run(inputTensorImage.buffer, outputBuffer.buffer);
    var result = _postProcessOutput(outputBuffer);
    return result;
  }

  static createModel(labels) async {
    final interpreter = await Interpreter.fromAsset(modelFileName);

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    print('Input shape: $inputShape');
    print('Output shape: $outputShape');

    // #3
    final inputType = interpreter.getInputTensor(0).type;
    final outputType = interpreter.getOutputTensor(0).type;

    print('Input type: $inputType');
    print('Output type: $outputType');

    return PodocoClassifierModel(
        interpreter: interpreter,
        inputShape: inputShape,
        outputShape: outputShape,
        inputType: inputType,
        outputType: outputType,
        labels: labels);
  }

  static loadLabels() async {
    List<String> rawLabels = await FileUtil.loadLabels(labelFileName);

    final labels = rawLabels
        .map((label) => label.substring(label.indexOf(' ')).trim())
        .toList();

    print('Labels: $labels');
    return labels;
  }
}

class LabelScore {
  var label;
  var score;

  LabelScore({required this.label, required this.score});
}

class ResultStatus {
  static const found = true;
  static const notFound = false;
}
