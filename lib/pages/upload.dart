import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleCamera()async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      this.file = file;
    });
  }

  handleGallery()async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery
    );
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Image With Camera'),
                onPressed: handleCamera,
              ),
              SimpleDialogOption(
                child: Text('Image With Gallery'),
                onPressed: handleGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: ()=> Navigator.pop(context),
              ),
            ],
          );
        }
    );
  }

  Container buildForm() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      color: Theme.of(context).accentColor,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/upload.svg',
              height: height / 2.5,
              width: width,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RaisedButton(
                    onPressed: ()=>selectImage(context),
                    child: Text(
                      'Upload Image',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: Color(0xFFFF5722),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  clearImage(){
    setState(() {
      file = null;
    });
  }

  compressImage()async{
    final tempDir = await getTemporaryDirectory();
    final path = await tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressImageFile = File('$path/img_$postId')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressImageFile;
    });

  }

  uploadImage(imageFile) async {
    StorageUploadTask storageUploadTask = await storageReference
        .child('post_$postId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFireStore({String mediaUrl, String description, String location}){
    postsRef
        .document(widget.currentUser.id)
        .collection('usersPosts')
        .document(postId)
        .setData({
      'ownerId' : widget.currentUser.id,
      'username' : widget.currentUser.username,
      'userid' : postId,
      'mediaUrl' : mediaUrl,
      'description' : description,
      'location' : location,
      'timestamp' : timestamp,
      'likes' : {}
    });

  }

  handleSubmit()async{
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFireStore(
      mediaUrl: mediaUrl,
      description: captionController.text,
      location: locationController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      isUploading = false;
      file = null;
    });
  }

  buildPostScreen(){
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Caption for Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black),
          onPressed: clearImage,
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : ()=> handleSubmit(),
            child: Text(
              'Post',
              style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold,fontSize: 20.0),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(''),
          Container(
            height: height /2.9,
            width: width,
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(file),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write caption for image',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop, color: Colors.orange,size: 40.0,
            ),
            title: Container(
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Add Location For Image',
                ),
              ),
            ),
          ),
          Container(
            height: 100.0,
            width: 200.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: getCurrentUserLocation,
                label:Text(
                  'Add Current Location',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                ),
              color: Color(0xFF5F9BFF),
              icon: Icon(Icons.my_location, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
  getCurrentUserLocation()async{
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    List<Placemark> marks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = marks[0];
    String completeAddress = '${placemark.locality},${placemark.subLocality}';
    locationController.text = completeAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildForm() : buildPostScreen();
  }
}
