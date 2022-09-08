import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class StatusBars extends StatelessWidget {
  @override
  StatusBars(this.exp, this.level);
  final int exp;
  final int level;
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Level: $level",
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(height: 5),
                StepProgressIndicator(
                  totalSteps: 100,
                  currentStep: this.exp,
                  selectedColor: Colors.red[700],
                  unselectedColor: Colors.red[200],
                  padding: 0,
                  size: 10,
                  roundedEdges: Radius.circular(10),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment(0.8, 0.6),
            child: Text("${(this.level) * 100 + this.exp}/${(this.level+1)*100}",
                style: TextStyle(fontSize: 16)),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Strength: ",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                StepProgressIndicator(
                  totalSteps: 10,
                  currentStep: 10,
                  selectedColor: Colors.red[700],
                  unselectedColor: Colors.red[200],
                  padding: 3.0,
                  size: 20,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Speed: ",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                StepProgressIndicator(
                  totalSteps: 10,
                  currentStep: 6,
                  selectedColor: Colors.red[700],
                  unselectedColor: Colors.red[200],
                  padding: 3.0,
                  size: 20,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Agility: ",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                StepProgressIndicator(
                  totalSteps: 10,
                  currentStep: 8,
                  selectedColor: Colors.red[700],
                  unselectedColor: Colors.red[200],
                  padding: 3.0,
                  size: 20,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Intelligence: ",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                StepProgressIndicator(
                  totalSteps: 10,
                  currentStep: 10,
                  selectedColor: Colors.red[700],
                  unselectedColor: Colors.red[200],
                  padding: 3.0,
                  size: 20,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health: ",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                StepProgressIndicator(
                  totalSteps: 10,
                  currentStep: 5,
                  selectedColor: Colors.red[700],
                  unselectedColor: Colors.red[200],
                  padding: 3.0,
                  size: 20,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Obedience: ",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                StepProgressIndicator(
                  totalSteps: 10,
                  currentStep: 7,
                  selectedColor: Colors.red[700],
                  unselectedColor: Colors.red[200],
                  padding: 3.0,
                  size: 20,
                ),
              ],
            ),
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}
