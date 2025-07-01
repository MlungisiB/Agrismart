import 'package:flutter/material.dart';
import 'package:agrismart/profile/user/user_data.dart';
import 'package:agrismart/profile/widgets/appbar_widget.dart';
import 'package:string_validator/string_validator.dart';
// This class handles the Page to edit the Phone Section of the User Profile.
class EditPhoneFormPage extends StatefulWidget {
  const EditPhoneFormPage({Key? key}) : super(key: key);
  @override
  EditPhoneFormPageState createState() {
    return EditPhoneFormPageState();
  }
}

class EditPhoneFormPageState extends State<EditPhoneFormPage> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  var user = UserData.myUser;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void updateUserValue(String phone) {

    if (phone.length == 8 && isNumeric(phone)) {
      String formattedPhoneNumber = "+268 " + phone;
      user.phone = formattedPhoneNumber;
    } else {
      // Handle invalid input (e.g., show an error message to the user)
      print("Invalid phone number format for Eswatini.");
      // You might want to return an error or update the UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                    width: 320,
                    child: Text(
                      "What's Your Phone Number?",
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: SizedBox(
                        height: 100,
                        width: 320,
                        child: TextFormField(
                          // Handles Form Validation
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            // Access isAlpha and isNumeric directly from the imported package
                            if (isAlpha(value)) {
                              return 'Only Numbers Please';
                            }
                            // Adjust length validation for 8-digit Eswatini number
                            if (value.length != 8) {
                              return 'Please enter an 8-digit phone number';
                            }
                            // You might also want to check if it's numeric here as a double check
                            if (!isNumeric(value)) {
                              return 'Only Numbers Please';
                            }
                            return null;
                          },
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Your Phone Number',
                          ),
                          keyboardType: TextInputType.number, // Suggest numeric keyboard
                        ))),
                Padding(
                    padding: const EdgeInsets.only(top: 150),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 320,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              // Access isNumeric directly from the imported package
                              if (_formKey.currentState!.validate()) {
                                // The validation in the TextFormField already checks for numeric and length
                                updateUserValue(phoneController.text);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              'Update',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        )))
              ]),
        ));
  }
}