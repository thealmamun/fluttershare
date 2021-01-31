import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePosts();
  }
  getProfilePosts()async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
    .document(widget.profileId)
    .collection('usersPosts')
    .orderBy('timestamp', descending: true)
    .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc)=>Post.fromDocument(doc)).toList();
    });
  }

  Column buildPostColumn(String label, int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Container buildButton({String text, Function function}){
    return Container(
      padding: EdgeInsets.only(top: 4.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 30.0,
          child: Text(
            text,
            style: TextStyle(fontWeight:FontWeight.bold, color: Colors.white,),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
              borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }
  editProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(currentUserId: currentUserId)));
  }

  buildProfileButton(){
    //return Text('Edit Profile');
    bool isProfileOwner = currentUserId == widget.profileId;
    if(isProfileOwner){
      return buildButton(
        text: 'Edit Profile',
        function: editProfile,
      );
    }
  }

  buildProfileHeader(){
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildPostColumn('Post',postCount),
                            buildPostColumn('Followers',0),
                            buildPostColumn('Following',0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                    user.username,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),

              ),
              Container(
                alignment: Alignment.centerLeft,
                //padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePost(){
    if(isLoading){
      return circularProgress();
    }
    return Column(
      children: posts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context ,titleText: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(height: 0.0),
          buildProfilePost(),
        ],
      ),
    );
  }
}
