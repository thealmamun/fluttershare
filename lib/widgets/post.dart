import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
   this.username,
   this.mediaUrl,
   this.location,
   this.postId,
   this.description,
   this.likes,
   this.ownerId
});
  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
       postId : doc['postId'],
       ownerId : doc['ownerId'],
       username : doc['username'],
       location : doc['location'],
       description : doc['description'],
       mediaUrl : doc['mediaUrl'],
       likes : doc['likes'],
    );
  }
  int getLikeCount(likes){
    if(likes  == 0){
      return 0;
    }
    int count = 0;
    likes.values.forEach((val){
      if(val == true){
        count += 1;
      }
    });
    return count;
  }
  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    description: this.description,
    mediaUrl: this.mediaUrl,
    likes: this.likes,
    likeCount: getLikeCount(this.likes),
  );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;

  _PostState({
    this.username,
    this.mediaUrl,
    this.location,
    this.postId,
    this.description,
    this.likes,
    this.ownerId,
    this.likeCount
  });

  buildPostHeader(){
    return FutureBuilder(
      future: userRef.document(ownerId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          ),
          title: GestureDetector(
            onTap: null,
            child: Text(
              user.username,
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: null),
        );
      }
    );
  }
  buildPostImage(){
    return GestureDetector(
      onDoubleTap: null,
      child: Column(
        children: <Widget>[
          Image.network(mediaUrl),
        ],
      ),
    );
  }
  buildPostFooter(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40, left: 20)),
            GestureDetector(
              onTap: null,
              child: Icon(
                Icons.favorite_border, size: 30.0, color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20)),
            GestureDetector(
              onTap: null,
              child: Icon(
                Icons.chat, size: 30.0, color: Colors.blue,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Text(
                '$likeCount likes',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Text(
                '$username',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Expanded(
              child: Text(description),
            ),
          ],
        )
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
