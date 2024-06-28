import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File? image;
  late ImagePicker imagePicker;
  late ImageLabeler imageLabeler;
  String result = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    final ImageLabelerOptions options =
        ImageLabelerOptions(confidenceThreshold: 0.5);
    imageLabeler = ImageLabeler(options: options);
  }

  chooseImage() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      image = File(selectedImage.path);
      performImageLabeling();
      setState(() {
        image;
      });
    }
  }

  captureImage() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (selectedImage != null) {
      image = File(selectedImage.path);
      performImageLabeling();
      setState(() {
        image;
      });
    }
  }

  performImageLabeling() async {
    InputImage inputImage = InputImage.fromFile(image!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    result = "";
    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      print(text);
      result += "$text   ${confidence.toStringAsFixed(2)}\n";
    }
    setState(() {
      result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.limeAccent.shade400,
        title: const Text('Recognizer'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Card(
                margin: EdgeInsets.all(10),
                color: Colors.grey.shade600,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  child: image == null
                      ? Icon(
                          Icons.image_outlined,
                          size: 150,
                        )
                      : Image.file(image!),
                ),
              ),
              Card(
                margin: EdgeInsets.all(10),
                color: Colors.limeAccent.shade400,
                child: Container(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.image,
                          size: 50,
                        ),
                        onTap: () {
                          chooseImage();
                        },
                      ),
                      Divider(),
                      InkWell(
                        child: Icon(
                          Icons.camera,
                          size: 50,
                        ),
                        onTap: () {
                          captureImage();
                        },
                      )
                    ],
                  ),
                ),
              ),
              Card(
                color: Colors.black,
                margin: EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  child: Text(result,style: TextStyle(fontSize: 32,color: Colors.white),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
