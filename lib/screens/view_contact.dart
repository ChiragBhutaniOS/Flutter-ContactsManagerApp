import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../data/blocs/bloc_provider.dart';
import '../data/blocs/view_contact_bloc.dart';
import '../models/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;



class ViewContactPage extends StatefulWidget {
	ViewContactPage({
		Key key,
		this.contact,
    this.isEditing,
    this.docDirectoryPath,
	}) : super(key: key);

	final Contact contact;
  final bool isEditing;
  final docDirectoryPath; 
  static const routeName = '/viewContact';


	@override
	_ViewContactPageState createState() => _ViewContactPageState();
}

class _ViewContactPageState extends State<ViewContactPage> {
	ViewContactBloc _viewContactBloc;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final landlineController = TextEditingController();
  bool inputValidationError = false;

  String docsDirectoryPath;

	@override
	void initState() {
		super.initState();

		_viewContactBloc = BlocProvider.of<ViewContactBloc>(context);

    if(widget.isEditing){
      nameController.text = widget.contact.name;
      mobileController.text = widget.contact.mobile.toString();
      if(widget.contact.landline == null){
        landlineController.text = '';
      }
      else{
       landlineController.text = widget.contact.landline.toString();
      }
    }
    else{
      nameController.text = '';
      mobileController.text = '';
      landlineController.text = '';

    }

	}


	void _addContact(BuildContext ctx ) async {
    if(nameController.text.length == 0 || mobileController.text.length == 0){
      showAlertDialog(ctx, 'Missing required fields!', 'Name and mobile can\'t be blank.');
      return;
      }
    
    widget.contact.id = DateTime.now().millisecondsSinceEpoch;
		widget.contact.name = nameController.text;
		widget.contact.mobile = int.parse(mobileController.text);

    if(landlineController.text.length > 0)
    {
      		widget.contact.landline = int.parse(landlineController.text);
    }
    else{
      		widget.contact.landline = null;
    }

		// Add the contact to the save contact stream. This triggers the function
		// we set in the listener.
		_viewContactBloc.inAddContact.add(widget.contact);

    Navigator.of(ctx).pop(true);
	}

	void _updateContact(BuildContext ctx) async {

    if(nameController.text.length == 0 || mobileController.text.length == 0){
      showAlertDialog(ctx, 'Missing required fields!', 'Name and mobile can\'t be blank.');
      return;
      }

		widget.contact.name = nameController.text;
		widget.contact.mobile = int.parse(mobileController.text);

    if(landlineController.text.length > 0)
    {
      		widget.contact.landline = int.parse(landlineController.text);
    }
    else{
      		widget.contact.landline = null;
    }

		// Add the updated contact to the save contact stream. This triggers the function
		// we set in the listener.
		_viewContactBloc.inSaveContact.add(widget.contact);
    Navigator.of(context).pop(true);
	}

	void _deleteContact() {
		// Add the note id to the delete note stream. This triggers the function
		// we set in the listener.
		_viewContactBloc.inDeleteContact.add(widget.contact.id);
		Navigator.of(context).pop(true);

	}

  void showAlertDialog(BuildContext cntxt, String title, String message){
    showDialog(
          context: cntxt,
          builder: (ctx) => AlertDialog(
                title: Text(title),
                content: Text(
                  message,
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              ),
        );
  }

  String _getPageTitle(){
    return widget.isEditing ? 'Update Contact' : 'Add New Contact';
  }

  void _showPhotoLibrary() async {
    final file = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(file != null)
    {
              // 5. Get the path to the apps directory so we can save the file to it.
      final Directory docsDirectory = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(file.path); // e.g. '.jpg'
      // final String fileExtension = path.extension(file.path); // e.g. '.jpg'

//  final newPath = '/Users/chiragbhutani/Library/Developer/CoreSimulator/Devices/AAA90D3D-1066-44B0-80ED-12BBE5616C40/data/Containers/Data/Application/4DADAE3D-5238-44D3-B397-335D55743122/Documents/image_picker_E3DA3CFD-05FC-4A88-9C69-67F9311AED60-39768-000248DC3ACF7FF6.jpg';
      final newPath = '${docsDirectory.path}/$fileName';
      await file.copy(newPath);

      setState(() {
       widget.contact.imgPath = fileName; 
    });
    }
  }

  void _toggleFavorite() {
    setState(() {
      if(widget.contact.isFav){
        widget.contact.isFav = false;
      }
      else{
        widget.contact.isFav = true;
      }
    });
  }
  

  Widget _buildLabelAndText(String title, TextEditingController textController, TextInputType keyboardInputType){
          return  Row(
              children : <Widget>[
                Container(
                  width: 100,
                  height: 24,
                  margin: EdgeInsets.fromLTRB(20, 0, 0, 10),
                  child: Text(
                    title,
                    style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,)
                  )
                ),
                Flexible(child: Padding(padding: const EdgeInsets.fromLTRB(0,0,0,20), child :
                Container(
                  height: 28,
                  width:  280,
                  decoration: BoxDecoration(
                   border: Border.all(color: Colors.black54),
                  ),
                  child: TextField(
                    controller: textController,
                    keyboardType: keyboardInputType,
                  ),
                ),
                ),
                ),
              ]
            );
  }

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(_getPageTitle()),
				actions: <Widget>[
					IconButton(
						icon: widget.contact.isFav ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_border, color: Colors.white),
						onPressed: _toggleFavorite,
					),
				],
			),
			body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
          FocusScope.of(context).unfocus();
          },
      child : SafeArea(child: Container(
				child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            MaterialButton(
              onPressed: _showPhotoLibrary,
              color: Colors.white,
              textColor: widget.contact.imgPath.length == 0 ? Colors.grey : Colors.white,
              child: 
              widget.contact.imgPath.length == 0 ? Icon(Icons.photo_camera, size: 100,) : Image.file(File('${widget.docDirectoryPath}/${widget.contact.imgPath}',), width: 100, height: 100), 
              padding: EdgeInsets.all(16),
              shape: CircleBorder(),
            ),
            
            SizedBox(height: 50,),
            _buildLabelAndText('Name', nameController, TextInputType.text),
            SizedBox(height: 10,),
            _buildLabelAndText('Mobile', mobileController, TextInputType.number),
            SizedBox(height: 10,),
            _buildLabelAndText('Landline', landlineController, TextInputType.number),
            Spacer(),
            Container(
              alignment: Alignment.bottomCenter,
              child : widget.isEditing ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children : <Widget>[
                  FlatButton(
                    child: Text(
                      'Update',     
                      style: TextStyle(fontSize: 20.0),
                      ),
                    textColor: Colors.blue,
                    onPressed: () => _updateContact(context)
                    
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text(
                      'Delete',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    textColor: Colors.blue,
                    onPressed: _deleteContact
                  ),
                ]) : FlatButton(
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    
                    textColor: Colors.blue,
                    onPressed: () => _addContact(context),
                  ),
              ),
          ],
        ) 
			),
      )
      )
		);
	}
}