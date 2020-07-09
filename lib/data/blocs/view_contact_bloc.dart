import 'dart:async';

import './bloc_provider.dart';
import '../database.dart';
import 'package:ContactsManagerApp/models/contact.dart';

class ViewContactBloc implements BlocBase {

	// Create a broadcast controller that allows this stream to be listened
	// to multiple times. This is the primary, if not only, type of stream we'll be using.
	final _contactsController = StreamController<List<Contact>>.broadcast();

	// Input stream. We add our contacts to the stream using this variable.
	StreamSink<List<Contact>> get _inContacts => _contactsController.sink;

	// Output stream. This one will be used within our pages to display the contacts.
	Stream<List<Contact>> get contacts => _contactsController.stream;

  
	final _saveContactController = StreamController<Contact>.broadcast();
	StreamSink<Contact> get inSaveContact => _saveContactController.sink;

	final _deleteContactController = StreamController<int>.broadcast();
	StreamSink<int> get inDeleteContact => _deleteContactController.sink;

	// This bool StreamController will be used to ensure we don't do anything
	// else until a contact is actually deleted from the database.
	final _contactDeletedController = StreamController<bool>.broadcast();
	StreamSink<bool> get _inDeleted => _contactDeletedController.sink;
	Stream<bool> get deleted => _contactDeletedController.stream;

  // Input stream for adding new contacts. We'll call this from our pages.
	final _addContactController = StreamController<Contact>.broadcast();
	StreamSink<Contact> get inAddContact => _addContactController.sink;


	ViewContactBloc() {

    // Retrieve all the contacts on initialization
		getContacts();

		// Listen for changes to the stream, and execute a function when a change is made
		_saveContactController.stream.listen(_handleSaveContact);
		_deleteContactController.stream.listen(_handleDeleteContact);

  	// Listens for changes to the addContactController and calls _handleAddContact on change
		_addContactController.stream.listen(_handleAddContact);

	}

	@override
	void dispose() {
	}

	void _handleSaveContact(Contact contact) async {
		await DBProvider.db.updateContact(contact);

    getContacts();
	}

	void _handleDeleteContact(int id) async {
		await DBProvider.db.deleteContact(id);

    getContacts();
	}



  void _handleAddContact(Contact contact) async {
		// Create the contact in the database
		await DBProvider.db.newContact(contact);

		// // Retrieve all the contacts again after one is added.
		// // This allows our pages to update properly and display the
		// // newly added contact.
		getContacts();
	}

	void getContacts() async {
		// Retrieve all the contacts from the database
		List<Contact> contacts = await DBProvider.db.getContacts();

		// Add all of the contacts to the stream so we can grab them later from our pages
		_inContacts.add(contacts);
	}


}