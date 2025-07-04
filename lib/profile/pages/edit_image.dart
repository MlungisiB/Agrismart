import 'dart:io';

import 'package:flutter/material.dart';
import 'package:agrismart/profile/user/user_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:agrismart/profile/widgets/appbar_widget.dart';
import 'package:image_picker/image_picker.dart';

class EditImagePage extends StatefulWidget {
  const EditImagePage({super.key});

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  var user = UserData.myUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
              width: 330,
              child: Text(
                "Upload a photo of yourself:",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: 330,
              child: GestureDetector(
                onTap: () async {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);

                  if (image == null) return;

                  final location = await getApplicationDocumentsDirectory();
                  final name = basename(image.path);
                  final imageFile = File('${location.path}/$name');
                  final newImage =
                  await File(image.path).copy(imageFile.path);

                  // Update the user object's imagePath with the local file path
                  setState(
                          () => user = user.copy(imagePath: newImage.path));
                },
                // Use Image.file to display the image from the local path
                child: user.image.isNotEmpty
                    ? Image.file(File(user.image)) // Check if user.image is not empty before using
                    : Image.asset('asset/user.jpg'), // Display a placeholder if no image
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 330,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  )))
        ],
      ),
    );
  }
}
