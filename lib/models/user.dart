import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String photoUrl;
  final String bio;

  User({
    this.id,
    this.email,
    this.username,
    this.displayName,
    this.photoUrl,
    this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
    );
  }

}
