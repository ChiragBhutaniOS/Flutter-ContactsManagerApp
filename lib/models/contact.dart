import 'package:flutter/material.dart';

class Contact {
	int id;
	String name;
  int mobile;
  int landline;
  String imgPath;
  bool isFav;  


	Contact({
		this.id,
		@required this.name,
    @required this.mobile,
    this.landline,
    this.imgPath,
    this.isFav
	});

	factory Contact.fromJson(Map<String, dynamic> json) => new Contact(
		id: json["id"],
		name: json["name"],
    mobile: json["mobile"],
    landline: json["landline"],
    imgPath: json["imgPath"],
    isFav: json["isFav"] == 1,
	);

	Map<String, dynamic> toJson() => {
		"id": id,
		"name": name,
    "mobile": mobile,
		"landline": landline,
		"imgPath": imgPath,
		"isFav": isFav ? 1 : 0,
	};
}