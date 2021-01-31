import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _textFieldController = TextEditingController();

  _onClear() {
    setState(() {
      _textFieldController.text = "";
    });
  }

  Future<QuerySnapshot>searchFutureResult;
  handleSearch(String query){
    Future<QuerySnapshot>users =
    userRef.where('displayName',isGreaterThanOrEqualTo: query).getDocuments();
    setState(() {
      searchFutureResult = users;
    });
  }

  AppBar buildSearchResult(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: _textFieldController,
        decoration: InputDecoration(
          hintText: 'Search For Users',
          prefixIcon: Icon(
            Icons.account_box,size: 30.0,
          ),
          suffixIcon: IconButton(
            onPressed: () => _onClear(),
            icon: Icon(Icons.clear),
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }
  Container buildNoContent(){
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: height/2.5,
              width: width,
            ),
            Text(
              'Find User',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 50.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  buildSearchContent(){
    return FutureBuilder(
      future: searchFutureResult,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<UserResult>searchResult = [];
        snapshot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          UserResult searchResults = UserResult(user);
          searchResult.add(searchResults);
        });
        return ListView(
          children: searchResult,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: buildSearchResult(),
      body: searchFutureResult == null ? buildNoContent() : buildSearchContent(),
    );
  }
}

class UserResult extends StatelessWidget {
  final user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: (){},
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
