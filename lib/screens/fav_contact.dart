import 'dart:io';

import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../data/database.dart';


class FavoriteContactPage extends StatefulWidget {
	FavoriteContactPage({
		Key key,
    this.docDirectoryPath,
	}) : super(key: key);
  final docDirectoryPath; 

  static const routeName = '/favoriteContact';

	@override
	_FavoriteContactPageState createState() => _FavoriteContactPageState();
}

class _FavoriteContactPageState extends State<FavoriteContactPage> {

  List<Contact> favContacts = <Contact>[];
	@override
	void initState() {
		super.initState();

    _getFavoriteContactlist();
    
	}

  void _getFavoriteContactlist() async{

		List<Contact> favContactsList = await DBProvider.db.getFavoriteContacts();

    setState(() {
      favContacts = favContactsList;
    });
  }

  Widget _buildListTile(Contact contact) {
    return ListTile(
      leading:  contact.imgPath.length > 0 ? 
      Image.file(File('${widget.docDirectoryPath}/${contact.imgPath}',), width: 48, height: 48) 
      : Image.asset('assets/images/user_icon.png',width: 48, height: 48),
      title: Text(
        contact.name,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: null,
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Contact List'),
      ),
      body: (favContacts != null && favContacts.length <= 0 ? Center(
                child :Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'No contacts marked as favorite',
                       style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
      )
      : SafeArea(
        child : Container(
        height: double.infinity,
        child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2,),
											itemCount: favContacts.length,
											itemBuilder: (BuildContext context, int index) {
												Contact contact = favContacts[index];

												return _buildListTile(contact);
                      },
										)
    ),
  )
    )
    );
  }
}
