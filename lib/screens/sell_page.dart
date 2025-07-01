import 'dart:io';
import 'package:agrismart/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrismart/widgets/random_scaffold.dart';
import 'package:agrismart/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SellPage extends StatefulWidget {
  const SellPage({Key? key}) : super(key: key);

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _formSellKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  bool _isLoading = false;
  File? _image;
  final List<String> _categories = [
    'Fruits', 'Vegetables', 'Crops', 'Seeds', 'Animal products', 'Plant products'
  ];
  String? _selectedCategory;

  // The URL to open
  final Uri _ehisUrl = Uri.parse('https://ehis.co.sz/');

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    print('Picked file: $pickedFile'); // Debug log
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image set: ${_image!.path}'); // Debug log
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _handleSellItem() async {
    if (!_formSellKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields correctly.')),
        );
      }
      return;
    }
    if (_image == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image.')),
        );
      }
      return;
    }
    if (_selectedCategory == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final supabase = Supabase.instance.client;
    final name = _nameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();

    final double? sellingPrice = double.tryParse(_sellingPriceController.text.trim());

    if (sellingPrice == null || sellingPrice <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid positive selling price.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final description = _descriptionController.text.trim();

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to sell items.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      final String imageFileName = 'product/${currentUser.id}/${DateTime.now().millisecondsSinceEpoch}-${_image!.path.split('/').last}';

      await supabase.storage
          .from('product')
          .upload(
        imageFileName,
        _image!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final String publicImageUrl = supabase.storage
          .from('product')
          .getPublicUrl(imageFileName);

      // Insert into products table
      await supabase.from('products').insert({
        'name': name,
        'description': description,
        'sellingprice': sellingPrice,
        'category': _selectedCategory,
        'image_path': publicImageUrl,
        'user_id': currentUser.id,
        // You may also want to store location and phone number here if they are product-specific
        // 'location': _locationController.text.trim(),
        // 'phone_number': phoneNumber,
      });

      // Update the signup table with the phone number
      await supabase
          .from('signup')
          .update({'phone': phoneNumber})
          .eq('user_id', currentUser.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
      }

      // Clear form fields and reset state
      _nameController.clear();
      _locationController.clear();
      _phoneNumberController.clear();
      _descriptionController.clear();
      _sellingPriceController.clear();
      setState(() {
        _image = null;
        _selectedCategory = null;
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(userEmail: '',),
          ),
        );
      }

    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: ${e.message}')),
        );
      }
    } on PostgrestException catch (e) {
      debugPrint('Supabase Database Error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item: ${e.message}')),
        );
      }
    } catch (e, stacktrace) {
      debugPrint('Unexpected error adding item: $e');
      debugPrintStack(stackTrace: stacktrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToProfilePage() {
    final supabase = Supabase.instance.client;
    final userEmail = supabase.auth.currentUser?.email;

    if (userEmail != null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userEmail: userEmail),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in!')),
        );
      }
    }
  }

  // Function to launch the URL
  Future<void> _launchEhisUrl() async {
    if (await canLaunchUrl(_ehisUrl)) {
      await launchUrl(_ehisUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $_ehisUrl')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RandomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 0,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 70,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSellKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- LINK ADDED HERE ---
                      TextButton(
                        onPressed: _launchEhisUrl,
                        child: Text(
                          'View Market Prices On EHIS',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: lightColorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Spacing between link and title
                      // --- END LINK ADDITION ---

                      Text(
                        'Enter Item to Sell',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _image != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _image!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.orange,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Select Image',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Item Name'
                            : null,
                        decoration: InputDecoration(
                          label: const Text('Item Name:'),
                          labelStyle: const TextStyle(color: Colors.green),
                          hintText: 'Enter Item Name',
                          hintStyle: const TextStyle(color: Colors.black12),
                          border: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        style: const TextStyle(color: Colors.orange),
                      ),
                      const SizedBox(height: 25.0),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select Category for your Item'
                            : null,
                        decoration: InputDecoration(
                          label: const Text('Category:'),
                          labelStyle: const TextStyle(color: Colors.green),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        items: _categories
                            .map((option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option,
                            style: const TextStyle(color: Colors.orange),
                          ),

                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 25.0),

                      TextFormField(
                        controller: _sellingPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: const Text('Selling Price: E'),
                          labelStyle: const TextStyle(color: Colors.green),
                          hintText: 'Enter Selling price per unit',
                          hintStyle: const TextStyle(color: Colors.black12),
                          border: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Item Price';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Please enter a valid positive price';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _locationController,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter Location' : null,
                        decoration: InputDecoration(
                          label: const Text('Location name:'),
                          labelStyle: const TextStyle(color: Colors.green),
                          hintText: 'Enter Location Name',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        style: const TextStyle(color: Colors.orange),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Your Phone Number'
                            : null,
                        decoration: InputDecoration(
                          label: const Text('+268'),
                          labelStyle: const TextStyle(color: Colors.green),
                          hintText: 'Enter Your phone number',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        style: const TextStyle(color: Colors.orange),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter Item Description' : null,
                        decoration: InputDecoration(
                          label: const Text('Description:'),
                          labelStyle: const TextStyle(color: Colors.green),
                          hintText: 'Enter Description',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        style: const TextStyle(color: Colors.orange),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            if (_formSellKey.currentState!.validate()) {
                              _handleSellItem();
                            }
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Sell Now'),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),

                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Sell Now',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}