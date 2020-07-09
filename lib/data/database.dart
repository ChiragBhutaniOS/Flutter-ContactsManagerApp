import 'dart:io';
import 'package:ContactsManagerApp/models/contact.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
    // Create a singleton
    DBProvider._();

    static final DBProvider db = DBProvider._();
    Database _database;

    Future<Database> get database async {
        if (_database != null) {
            return _database;
        }

        _database = await initDB();
        return _database;
    }

    initDB() async {
        // Get the location of our app directory. This is where files for our app,
        // and only our app, are stored. Files in this directory are deleted
        // when the app is deleted.
        Directory documentsDir = await getApplicationDocumentsDirectory();
        String path = join(documentsDir.path, 'app.db');

        return await openDatabase(path, version: 1, onOpen: (db) async {
        }, onCreate: (Database db, int version) async {
            // Create the contact table
            await db.execute('''
                CREATE TABLE contact(
                    id INTEGER PRIMARY KEY,
                    name TEXT DEFAULT '',
                    mobile INTEGER,
                    landline INTEGER,
                    imgPath TEXT,
                    isFav INTEGER
                )
            ''');
        });
    }

newContact(Contact contact) async {
    final db = await database;
    var res = await db.insert('contact', contact.toJson());
    return res;
}

getContacts() async {
    final db = await database;
    var res = await db.query('contact', orderBy: 'name');
    // var res = await db.rawQuery('SELECT * FROM contact ORDER BY name ASC');
    List<Contact> contacts = res.isNotEmpty ? res.map((contact) => Contact.fromJson(contact)).toList() : [];

    return contacts;
}

getFavoriteContacts() async {
    final db = await database;
    var res =await  db.query("contact", where: "isFav = 1", orderBy: "name");

    List<Contact> contacts = res.isNotEmpty ? res.map((contact) => Contact.fromJson(contact)).toList() : [];

    return contacts;
}


updateContact(Contact contact) async {
    final db = await database;
    var res = await db.update('contact', contact.toJson(), where: 'id = ?', whereArgs: [contact.id]);

    return res;
}

deleteContact(int id) async {
    final db = await database;

    db.delete('contact', where: 'id = ?', whereArgs: [id]);
}

}