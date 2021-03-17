import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: Text("Food360")),
      body: Center(
        child: MainForm(),
      ),
    ));
  }
}

class MainForm extends StatefulWidget {
  @override
  _MainFormState createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> {
  final imageURLController = TextEditingController();
  final imageURLFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageURLFocusNode.addListener(() {
      if (!imageURLFocusNode.hasFocus) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.2,
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Form(
          child: Column(
            children: [
              imageURLController.text.isEmpty
                  ? Text('Image Placeholder')
                  : FittedBox(child: Image.network(imageURLController.text)),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter image src URL',
                ),
                controller: imageURLController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                focusNode: imageURLFocusNode,
              ),
              Container(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                ElevatedButton(onPressed: () {setState(() {});},
                child: Text("Preview")),
                ElevatedButton(onPressed: () {setState(() {});},
                child: Text("Submit")),
              ],),
              margin: EdgeInsets.only(top: 10),)
              
            ],
          ),
        ));
  }
}
