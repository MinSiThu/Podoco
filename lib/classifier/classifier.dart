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

  PodocoClassifierModel({
    required this.interpreter,
    required this.inputShape,
    required this.outputShape,
    required this.inputType,
    required this.outputType,
  });


  static createModel() async {
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
        outputType: outputType);
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

class ResultStatus{
  static const found = true;
  static const notFound = false;
}