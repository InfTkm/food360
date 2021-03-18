import 'dart:html';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  var cansubmit = false;
  // final imageURLFocusNode = FocusNode();
  var results = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // imageURLFocusNode.addListener(() {
    //   if (!imageURLFocusNode.hasFocus) {
    //     setState(() {});
    //   }
    // });
  }

  void submit() async {
    var url = Uri.http('8c26d2a9fc14.ngrok.io', '/api/infer');

    var res = await http.post(url,
        body: json.encode({'src': imageURLController.text}),
        encoding: Encoding.getByName('utf-8'),
        headers: {"Content-Type": "application/json"});
    results = res.body.split(';');

    setState(() {});
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
              Container(
                child:
                (imageURLController.text.isEmpty ||
                        !imageURLController.text.startsWith('http'))
                    ? Text('Image Placeholder')
                    : Image.network(imageURLController.text),
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.8,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter image src URL',
                ),
                onChanged: (text) {
                  setState(() {});
                },
                controller: imageURLController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                // focusNode: imageURLFocusNode,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          // if (imageURLController.text.startsWith('http')) {

                          // }
                        },
                        child: Text("Preview")),
                    ElevatedButton(
                        onPressed: this.submit, child: Text("Submit"))
                  ],
                ),
                margin: EdgeInsets.only(top: 10),
              ),
              Column(
                children: results.map((r) {
                  return Text(r);
                }).toList(),
              )
            ],
          ),
        ));
  }
}
