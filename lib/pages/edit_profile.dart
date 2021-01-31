import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  TextEditingController displayController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }
  getUser()async{
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
              'Displayname',
            style: TextStyle(fontSize: 20.0, color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayController,
          decoration: InputDecoration(
            hintText: 'Update Display Name',
              errorText: _displayValid ? null : 'display name is not empty',
          ),
        ),
      ],
    );
  }
  Column buildBioField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Bio',
            style: TextStyle(fontSize: 20.0, color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: 'Update Bio',
            errorText: _bioValid ? null : 'Bio is not empty , minimum 100 word is required'
          ),
        ),
      ],
    );
  }

  updateProfileData(){
    setState(() {
      displayController.text.trim().length < 3 ||
      displayController.text.isEmpty ? _displayValid = false : _displayValid = true;
      bioController.text.trim().length > 100 ? _bioValid = false : _bioValid = true;
    });
    if(_displayValid && _bioValid){
      userRef.document(widget.currentUserId).updateData({
        'displayName' : displayController.text,
        'bio' : bioController.text,
      });
    }
    SnackBar snackBar = SnackBar(content: Text('Profile Updated'));
    _scaffoldkey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
            'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: ()=>Navigator.pop(context),
            icon: Icon(Icons.done, size: 30.0, color: Colors.green,),
          ),
        ],
      ),
      body: isLoading ? circularProgress() : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: CircleAvatar(
                    maxRadius: 50.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildBioField(),
                    ],
                  ),
                ),
                RaisedButton(
                    onPressed: updateProfileData,
                  child: Text(
                    'Update Profile',
                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(12.0),
                  child: FlatButton.icon(
                      onPressed: null, icon: Icon(Icons.cancel, color: Colors.red,),
                      label: Text(
                          'LogOut',
                        style: TextStyle(fontSize: 20.0, color: Colors.red),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
