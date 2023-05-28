import 'package:flutter/material.dart';
import 'package:podoco_plant_diesease_classifier/classifier/classifier.dart';

class ResultTextBox extends StatelessWidget {
  LabelScore labelScore;

  ResultTextBox({
    required this.labelScore
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child:Column(
        children:[
          Text(labelScore.label,style: TextStyle(
            fontSize:24
          ),),
          Text("Accuracy - ${labelScore.score}")
        ]
      )
    );
  }
}