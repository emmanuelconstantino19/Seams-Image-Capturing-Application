import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

//void main() => runApp(MyApp());
void main() {
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs: prefs));
  });
}


class MyApp extends StatelessWidget {

  MyApp({Key key, this.prefs}) : super(key: key);
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.orangeAccent,
      ),
      // Initially display FirstPage
      home: _decideMainPage(),
    );
  }

  _decideMainPage() {
    if (prefs.getString('userType') != null) {
        return FirstPage(title: 'SARAI');
        // return RegistrationPage(prefs: prefs);
    } else {
      return EntryPage();
    }
  }
}

class EntryPage extends StatefulWidget {
  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final TextEditingController fnameControl = new TextEditingController();
  final TextEditingController lnameControl = new TextEditingController();
  final TextEditingController contactControl = new TextEditingController();
  String _value;

  addStringToSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //print(fnameControl.text);
    prefs.setString('fname', fnameControl.text);
    prefs.setString('lname', lnameControl.text);
    prefs.setString('contact', contactControl.text);
    prefs.setString('userType', _value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: new Image.asset('images/sarai_logo.png', fit: BoxFit.cover),
        actions: <Widget>[
          new Image.asset('images/dost-pcaarrd-uplb.png', fit: BoxFit.cover),
        ],
      ),
      body:

      /*Center(
          //mainAxisAlignment: MainAxisAlignment.center,
        child: _myListView(context)
      ));*/
      Center(
          child: SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      margin: const EdgeInsets.only(bottom: 70.0),
                      child: Image.asset(
                          'images/seamslogo.png',
                          fit: BoxFit.cover
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      margin: const EdgeInsets.only(bottom: 30.0),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your first name'
                            ),
                            controller: fnameControl,
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                          ),
                          TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your last name'
                            ),
                            controller: lnameControl,
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                          ),
                          TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your contact number'
                            ),
                            keyboardType: TextInputType.number,
                            controller: contactControl,
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                          ),
                          DropdownButton<String>(
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String>(
                                child: Text('Farmer'),
                                value: 'Farmer',
                              ),
                              DropdownMenuItem<String>(
                                child: Text('LGU/Partner'),
                                value: 'LGU/Partner',
                              ),
                              DropdownMenuItem<String>(
                                child: Text('SARAi'),
                                value: 'SARAi',
                              ),
                            ],
                            onChanged: (String value) {
                              setState(() {
                                _value = value;
                              });
                            },
                            hint: Text('Select user type'),
                            value: _value,
                          ),
                        ],
                      )
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                        padding: const EdgeInsets.all(10.0),
                        textColor: Colors.white,
                        color: Colors.green,
                        onPressed: (){
                          //Navigator.of(context).pop();
                          //_openGallery(context);
                          addStringToSF();
                          Navigator.of(context).pushReplacement(
                            // With MaterialPageRoute, you can pass data between pages,
                            // but if you have a more complex app, you will quickly get lost.
                            MaterialPageRoute(
                              builder: (context) =>
                              //NotesPage(data: picture),
                              FirstPage(title: 'SARAI'),
                            ),
                          );
                        },
                        child:Text('Submit',style: new TextStyle(
                          fontSize: 25.0,
                        )),
                      ),
                    ),
                  ]
              )
          )
      ),
    );
  }
}


class FirstPage extends StatefulWidget {
  FirstPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  File imageFile;

  var location = new Location();

  Map<String, double> userLocation;

  Future<Map<String, double>> _getLocation() async {
    var currentLocation = <String, double>{};
    try {
      //currentLocation = await location.getLocation();
      currentLocation = null;
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

//  _openGallery(BuildContext context) async {
//    var picture = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 480, maxHeight: 640);
//    this.setState((){
//      imageFile = picture;
//    });
//    if(picture != null) {
//      final result = await Navigator.of(context).push(
//        // With MaterialPageRoute, you can pass data between pages,
//        // but if you have a more complex app, you will quickly get lost.
//        MaterialPageRoute(
//          builder: (context) =>
//              //NotesPage(data: picture),
//              purposePage(data: picture),
//        ),
//      );
//    }
//  }

  _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 480, maxHeight: 640);
    picture = await FlutterExifRotation.rotateImage(path: picture.path);
    this.setState((){
      imageFile = picture;
      _save(imageFile);
    });
    if(picture != null) {
      Navigator.of(context).push(
        // With MaterialPageRoute, you can pass data between pages,
        // but if you have a more complex app, you will quickly get lost.
        MaterialPageRoute(
          builder: (context) =>
              //NotesPage(data: picture),
              purposePage(data: picture),
        ),
      );
    }
  }

  _save(File imageFile) async {
    List<int> imageBytes = imageFile.readAsBytesSync();
    print("-----------------___START------------");
    final result = await ImageGallerySaver.saveImage(imageBytes);
    print("-----------------END------------");
    print('RESULTS:' + result);
//    imageFile.readAsBytes().then((data) => ImageGallerySaver.saveImage(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: new Image.asset('images/sarai_logo.png', fit: BoxFit.cover),
        actions: <Widget>[
          new Image.asset('images/dost-pcaarrd-uplb.png', fit: BoxFit.cover),
        ],
      ),
      body:

      /*Center(
          //mainAxisAlignment: MainAxisAlignment.center,
        child: _myListView(context)
      ));*/
      Center(
      child: SingleChildScrollView(
          child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  margin: const EdgeInsets.only(bottom: 70.0),
                  child: Image.asset(
                      'images/seamslogo.png',
                      fit: BoxFit.cover
                  ),
                ),

                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                  child: Text('Take a photo by clicking the button below.',style: new TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Roboto',
                  ),textAlign: TextAlign.center,)
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child:RaisedButton(
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)), //10.0 before
                    padding: const EdgeInsets.all(30.0),
                    textColor: Colors.white,
                    color: Colors.green,
                    onPressed: (){
                      //Navigator.of(context).pop();
                      _openCamera(context);
                    },
                    child:Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.camera_alt, size: 60.0), Text('Camera',style: new TextStyle(
                          fontSize: 30.0,
                        ))]),
                  ),
                ),
//                Container(
//                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
//                  child: RaisedButton(
//                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
//                    padding: const EdgeInsets.all(30.0),
//                    textColor: Colors.white,
//                    color: Colors.green,
//                    onPressed: (){
//                      //Navigator.of(context).pop();
//                      _openGallery(context);
//                    },
//                    child:Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: [Icon(Icons.photo_library, size: 60.0), Text('Gallery',style: new TextStyle(
//                          fontSize: 30.0,
//                        ))]),
//                  ),
//                ),
              ]
          )
        )
      ),
      );
  }
}

class NotesPage extends StatefulWidget {
  // This is a String for the sake of an example.
  // You can use any type you want.
  final File data;
  final String purpose;
  final String crop;
  final String stage;
  //final _formKey = GlobalKey<FormState>();


  NotesPage({
    Key key,
    @required this.data,
    @required this.purpose,
    @required this.crop,
    @required this.stage,
  }) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();

}

class _NotesPageState extends State<NotesPage> {
  final db = Firestore.instance;
  String id;
  final TextEditingController titleControl = new TextEditingController();
  final TextEditingController descriptionControl = new TextEditingController();
  bool _isButtonDisabled = false;

  /*Future uploadPic(BuildContext context) async{
    String fileName = basename(widget.data.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(widget.data);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    setState(() {
      createData(context,downloadUrl);
    });
  }*/

  void createData(BuildContext context, String downloadUrl) async {
    var location = new Location();
    var currentLocation;
    try {
      List<int> imageBytes = widget.data.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      currentLocation = await location.getLocation();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var now = new DateTime.now();
      db.collection('post').add({'imageUrl': base64Image, 'dateTaken':now, 'first_name': prefs.getString('fname'), 'last_name': prefs.getString('lname'), 'user_type': prefs.getString('userType') , 'contact': prefs.getString('contact'), 'crop': widget.crop, 'stage': widget.stage, 'purpose': widget.purpose, 'title':titleControl.text, 'description':descriptionControl.text, 'coords': [currentLocation.latitude, currentLocation.longitude]
      });
      setState(() {
        //id = ref.documentID;
        Navigator.of(context).push(
          // With MaterialPageRoute, you can pass data between pages,
          // but if you have a more complex app, you will quickly get lost.
            MaterialPageRoute(
              builder: (context) =>
              //NotesPage(data: picture),
              successPage(),
            )
        );
      });
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        var error = 'Permission denied';
      }
      currentLocation = null;
    }


  }



  Widget _decideImageView(){
    if(widget.data == null){
      return Text("No Image Selected!");
    }else{
      return Image.file(widget.data,width: 300,height: 300);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Image.asset('images/sarai_logo.png', fit: BoxFit.cover),
        actions: <Widget>[
          new Image.asset('images/dost-pcaarrd-uplb.png', fit: BoxFit.cover),
        ],
      ),
      body:
      Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  child: _decideImageView(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                margin: const EdgeInsets.only(top: 20.0),
                child: TextField(
                  decoration: InputDecoration(

                      hintText: 'Title (Required)',
                      border: OutlineInputBorder(),
                  ),
                  controller: titleControl,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                child: TextField(
                  decoration: InputDecoration(

                    hintText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  controller: descriptionControl,
                ),
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40.0),
                  decoration: new BoxDecoration(
                    //border: new Border.all(color: Colors.black),
                    borderRadius: BorderRadius.all(
                        Radius.circular(5.0) //         <--- border radius here
                    ),
                  ),
                  child:
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text('Crop: ' + widget.crop,style: new TextStyle(
                            fontSize: 25.0,
                            fontFamily: 'Roboto',
                          ),textAlign: TextAlign.left,),
                        ),
                        Container(
                          child:
                          Text('Purpose: ' + widget.purpose,style: new TextStyle(
                            fontSize: 25.0,
                            fontFamily: 'Roboto',
                          ),textAlign: TextAlign.left,),
                        ),
                        Container(
                          child: Text('Growth stage: ' + widget.stage,style: new TextStyle(
                            fontSize: 25.0,
                            fontFamily: 'Roboto',
                          ),textAlign: TextAlign.left,),
                        ),
                      ]
                  )
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                  padding: const EdgeInsets.all(10.0),
                  textColor: Colors.white,
                  color: _isButtonDisabled ? Colors.grey : Colors.green,
                  onPressed: (){
                    //Navigator.of(context).pop();
                    //uploadPic(context);
                    if(!_isButtonDisabled){
                      //uploadPic(context);
                      createData(context,'');
                    }
                    setState(() => _isButtonDisabled = true);
                  },
                  child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text(_isButtonDisabled ? 'Loading...' : 'Submit',style: new TextStyle(
                        fontSize: 30.0,
                      ))]),
                ),
              ),
            ]
          )
        )
      )
    );
  }

}


class purposePage extends StatefulWidget {
  final File data;

  var purpose;

  purposePage({
    Key key,
    @required this.data,
  }) : super(key: key);

  @override
  _purposePageState createState() => _purposePageState();
}

class _purposePageState extends State<purposePage> {
  _moveToNextPage(BuildContext context, String text){
    Navigator.of(context).push(
      // With MaterialPageRoute, you can pass data between pages,
      // but if you have a more complex app, you will quickly get lost.
      MaterialPageRoute(
        builder: (context) =>
        //NotesPage(data: picture),
        cropPage(data: widget.data, purpose: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Image.asset('images/sarai_logo.png', fit: BoxFit.cover),
        actions: <Widget>[
          new Image.asset('images/dost-pcaarrd-uplb.png', fit: BoxFit.cover),
        ],
      ),
      body:
      Center(
        child: SingleChildScrollView(
              child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal:15.0),
              child: Text('How would you like to use the image?',style: new TextStyle(
                fontSize: 40.0,
                fontFamily: 'Roboto',
              ),textAlign: TextAlign.center,),
            ),


            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              margin: const EdgeInsets.only(top: 50.0, bottom: 20.0),
              child: RaisedButton(
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                padding: const EdgeInsets.all(30.0),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: (){
                  _moveToNextPage(context,'Monitoring');
                },
                child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Monitoring',style: new TextStyle(
                      fontSize: 30.0,
                    ))]),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              margin: const EdgeInsets.only(bottom: 20.0),
              child:  RaisedButton(
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                padding: const EdgeInsets.all(30.0),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: (){
                  _moveToNextPage(context, 'Reporting');
                },
                child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Reporting',style: new TextStyle(
                      fontSize: 30.0,
                    ))]),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              margin: const EdgeInsets.only(bottom: 20.0),
              child:  RaisedButton(
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                padding: const EdgeInsets.all(30.0),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: (){
                  _moveToNextPage(context,'Inquiry');
                },
                child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Inquiry',style: new TextStyle(
                      fontSize: 30.0,
                    ))]),
              ),
            )

            ]
        ),

        )
      )
    );
  }
}

class cropPage extends StatefulWidget {
  final File data;
  final String purpose;

  cropPage({
    Key key,
    @required this.data,
    @required this.purpose,
  }) : super(key: key);

  @override
  _cropPageState createState() => _cropPageState();
}

class _cropPageState extends State<cropPage> {
  final TextEditingController othersControl = new TextEditingController();

  _moveToNextPage(BuildContext context, String text){
    Navigator.of(context).push(
      // With MaterialPageRoute, you can pass data between pages,
      // but if you have a more complex app, you will quickly get lost.
      MaterialPageRoute(
        builder: (context) =>
        //NotesPage(data: picture),
        stagePage(data: widget.data, purpose: widget.purpose, crop: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Image.asset('images/sarai_logo.png', fit: BoxFit.cover),
        actions: <Widget>[
          new Image.asset('images/dost-pcaarrd-uplb.png', fit: BoxFit.cover),
        ],
      ),
      body:

      Center(
          child: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal:15.0),
                    child: Text('What is the crop planted in the image?',style: new TextStyle(
                      fontSize: 40.0,
                      fontFamily: 'Roboto',
                    ),textAlign: TextAlign.center,),
                  ),


                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                    child: RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(30.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context,'Rice');
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Rice',style: new TextStyle(
                            fontSize: 30.0,
                          ))]),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child:  RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(30.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context, 'Corn');
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Corn',style: new TextStyle(
                            fontSize: 30.0,
                          ))]),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child:
                      TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(0)),
                            ),
                            hintText: 'Others, please specify'
                        ),
                        controller: othersControl,
                      ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child:  RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(10.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context, othersControl.text);
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Enter',style: new TextStyle(
                            fontSize: 20.0,
                          ))]),
                    ),
                  ),

                ]
            ),

          )
      )

    );
  }
}

class stagePage extends StatefulWidget {
  final File data;
  final String purpose;
  final String crop;

  stagePage({
    Key key,
    @required this.data,
    @required this.purpose,
    @required this.crop,
  }) : super(key: key);

  @override
  _stagePageState createState() => _stagePageState();
}

class _stagePageState extends State<stagePage> {
  final TextEditingController othersControl = new TextEditingController();

  _moveToNextPage(BuildContext context, String text){
    Navigator.of(context).push(
      // With MaterialPageRoute, you can pass data between pages,
      // but if you have a more complex app, you will quickly get lost.
      MaterialPageRoute(
        builder: (context) =>
        //NotesPage(data: picture),
        NotesPage(data: widget.data, purpose: widget.purpose, crop: widget.crop, stage: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Image.asset('images/sarai_logo.png', fit: BoxFit.cover),
        actions: <Widget>[
          new Image.asset('images/dost-pcaarrd-uplb.png', fit: BoxFit.cover),
        ],
      ),
      body:

      Center(
          child: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal:15.0),
                    child: Text('What is the crop growth stage in the image?',style: new TextStyle(
                      fontSize: 40.0,
                      fontFamily: 'Roboto',
                    ),textAlign: TextAlign.center,),
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Text('Scroll to see more options',style: new TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Roboto',
                      ),textAlign: TextAlign.center,)
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child:  RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(20.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context, 'Land Preparation');
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Land Preparation',style: new TextStyle(
                            fontSize: 30.0,
                          ))]),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(20.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context,'Vegetative');
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Vegetative',style: new TextStyle(
                            fontSize: 30.0,
                          ))]),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child:  RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(20.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context, 'Reproductive');
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Reproductive',style: new TextStyle(
                            fontSize: 30.0,
                          ))]),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child:  RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(20.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context,'Mature');
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Mature',style: new TextStyle(
                            fontSize: 30.0,
                          ))]),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child:  RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(20.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context,'Idle land/grass');
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Idle land/grass',style: new TextStyle(
                            fontSize: 30.0,
                          ))]),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child:  RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(20.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context,'Harvested');
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Harvested',style: new TextStyle(
                            fontSize: 30.0,
                          ))]),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child:
                    TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          hintText: 'Others, please specify'
                      ),
                      controller: othersControl,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child:  RaisedButton(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                      padding: const EdgeInsets.all(10.0),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: (){
                        _moveToNextPage(context, othersControl.text);
                      },
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Enter',style: new TextStyle(
                            fontSize: 20.0,
                          ))]),
                    ),
                  ),

                ]
            ),

          )
      )

    );
  }
}


class successPage extends StatefulWidget {
  @override
  _successPageState createState() => _successPageState();
}

class _successPageState extends State<successPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: new Image.asset('images/sarai_logo.png', fit: BoxFit.cover),
    actions: <Widget>[
    new Image.asset('images/dost-pcaarrd-uplb.png', fit: BoxFit.cover),
    ],
    ),
    body:

      Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(50.0),
                child:Image.asset('images/check.png', fit: BoxFit.cover),
              ),

              Container(
                child: Text('Thank you! Your photo has been successfully queued.',style: new TextStyle(
                  fontSize: 25.0,
                  fontFamily: 'Roboto',
                ),textAlign: TextAlign.center),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 100.0),
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                  padding: const EdgeInsets.all(10.0),
                  textColor: Colors.white,
                  color: Colors.green,
                  onPressed: (){
                    Navigator.pushAndRemoveUntil(
                      context,
                      // With MaterialPageRoute, you can pass data between pages,
                      // but if you have a more complex app, you will quickly get lost.
                      MaterialPageRoute(
                        builder: (context) =>
                        //NotesPage(data: picture),
                        FirstPage(title: 'SARAI'),
                      ),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Go back',style: new TextStyle(
                        fontSize: 30.0,
                      ))]),
                ),
              ),

            ]
          )
        )
      )
    );
  }
}






