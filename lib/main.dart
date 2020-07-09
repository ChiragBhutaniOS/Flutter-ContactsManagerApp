import 'package:flutter/material.dart';
import './data/blocs/bloc_provider.dart';
import './data/blocs/view_contact_bloc.dart';
import './models/contact.dart';
import './screens/view_contact.dart';
import 'package:ContactsManagerApp/screens/fav_contact.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Contact List',
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			home: BlocProvider(
				bloc: ViewContactBloc(),
				child: ContactsPage(title: 'Contact List'),
			),
		);
	}
}

class ContactsPage extends StatefulWidget {
	ContactsPage({
		Key key,
		this.title
	}) : super(key: key);

	final String title;

	@override
	_ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
	ViewContactBloc _contactsBloc;
  String docDirectoryPath;

	@override
	void initState() {
		super.initState();

		// Thanks to the BlocProvider providing this page with the ContactsBloc,
		// we can simply use this to retrieve it.
		_contactsBloc = BlocProvider.of<ViewContactBloc>(context);
    _contactsBloc.getContacts();

    loadDocumentsDirectoryPath();
	}

  loadDocumentsDirectoryPath() async{

    final Directory docsDirectory = await getApplicationDocumentsDirectory();

    setState(() {
      docDirectoryPath = docsDirectory.path;
    });
  }

	void _pushAddContactScreen() async {

    Contact contact = new Contact(id: 0, name: '', mobile: 0, landline: 0, imgPath: '', isFav: false);

    Navigator.of(context).push(
			MaterialPageRoute(
				// Once again, use the BlocProvider to pass the ViewContactBloc
				// to the ViewCOntactPage
				builder: (context) => BlocProvider(
					bloc: _contactsBloc,
					child: ViewContactPage(
						contact: contact,
            isEditing: false,
            docDirectoryPath: docDirectoryPath,
					),
				),
			),
		);

	}

	void _pushFavoriteContactScreen() async {

    Navigator.of(context).push(
			MaterialPageRoute(builder: (_) {
        return FavoriteContactPage(
          docDirectoryPath: docDirectoryPath,
        );
      },
			),
		);
	}


	void _navigateToContact(Contact contact, bool isEditing) async {
		// Push ViewContactPage, and store any return value in update. This will
		// be used to tell this page to refresh the copntact list after one is deleted.
		// If a contact isn't deleted, this will be set to null and the contact list will
		// not be refreshed.
		bool update = await Navigator.of(context).push(
			MaterialPageRoute(
				// Once again, use the BlocProvider to pass the ViewContactBloc
				// to the ViewCOntactPage
				builder: (context) => BlocProvider(
					bloc: _contactsBloc,
					child: ViewContactPage(
						contact: contact,
            isEditing: isEditing,
            docDirectoryPath: docDirectoryPath,
					),
				),
			),
		);

		// If update was set, get all the contacts again
		if (update != null) {
			_contactsBloc.getContacts();
		}
	}


  Widget _buildListTile(Contact contact, Function tapHandler) {
    return ListTile(
      leading: docDirectoryPath != null ? 
    (contact.imgPath.length > 0 ? 
      Image.file(File('$docDirectoryPath/${contact.imgPath}'), width: 48, height: 48) 
      : Image.asset('assets/images/user_icon.png',width: 48, height: 48))
      : Image.asset('assets/images/user_icon.png',width: 48, height: 48),
      title: Text(
        contact.name,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

Widget buildListTileForDrawer(String title, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(widget.title),
			),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
          children: <Widget>[
            buildListTileForDrawer('Contact list screen', Icons.contacts, () {
              Navigator.of(context).pushReplacementNamed('/');
            }),
            Divider(thickness: 2,),
            buildListTileForDrawer('Favorite contacts', Icons.favorite, () {
              _pushFavoriteContactScreen();
            }),
            Divider(thickness: 2,),
            buildListTileForDrawer('Add New Contact', Icons.person_add, () {
              _pushAddContactScreen();
            }),
          ],
        ),
      ),
    ),
			body: Container(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Expanded(
							// The streambuilder allows us to make use of our streams and display
							// that data on our page. It automatically updates when the stream updates.
							// Whenever you want to display stream data, you'll use the StreamBuilder.
							child: StreamBuilder<List<Contact>>(
								stream: _contactsBloc.contacts,
								builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
									// Make sure data exists and is actually loaded
									if (snapshot.hasData) {
										// If there are no contacts (data), display this message.
										if (snapshot.data.length == 0) {
											return Center(child:  Text('No Contacts', style:TextStyle(fontSize : 24)),) ;
										}

										List<Contact> contacts = snapshot.data;

										return ListView.separated(
                      separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2,),
											itemCount: snapshot.data.length,
											itemBuilder: (BuildContext context, int index) {
												Contact contact = contacts[index];

												return _buildListTile(contact, () {
                          _navigateToContact(contact, true);
                        });
											},
										);
									}

									// If the data is loading in, display a progress indicator
									// to indicate that. You don't have to use a progress
									// indicator, but the StreamBuilder has to return a widget.
									return Center(
										child: CircularProgressIndicator(),
									);
								},
							),
						),
					],
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: _pushAddContactScreen,
				child: Icon(Icons.add),
			),
		);
	}
}