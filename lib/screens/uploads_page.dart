import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrismart/theme/theme.dart';

class UploadsPage extends StatefulWidget {
  const UploadsPage({super.key, required this.userEmail});
  final String userEmail;

  @override
  _UploadsPageState createState() => _UploadsPageState();
}

class _UploadsPageState extends State<UploadsPage> {
  bool _isOpen = false;
  final PanelController _panelController = PanelController();
  final supabase = Supabase.instance.client;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FractionallySizedBox(
            alignment: Alignment.topCenter,
            heightFactor: 0.7,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg3.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: 0.3,
            child: Container(
              color: Colors.white,
            ),
          ),

          /// Sliding Panel
          SlidingUpPanel(
            controller: _panelController,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(32),
              topLeft: Radius.circular(32),
            ),
            minHeight: MediaQuery.of(context).size.height * 0.35,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            body: GestureDetector(
              onTap: () => _panelController.close(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            panelBuilder: (ScrollController controller) =>
                _panelBody(controller),
            onPanelSlide: (value) {
              if (value >= 0.2) {
                if (!_isOpen) {
                  setState(() {
                    _isOpen = true;
                  });
                }
              }
            },
            onPanelClosed: () {
              setState(() {
                _isOpen = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _panelBody(ScrollController controller) {
    double hPadding = 40;

    return SingleChildScrollView(
      controller: controller,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            height: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _titleSection(),
                //_infoSection(),
                _actionSection(hPadding: hPadding),
              ],
            ),
          ),
          // Remove GridView and replace with a non-scrollable list of images
          _imageGrid(),
        ],
      ),
    );
  }

  Widget _imageGrid() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchImagePaths(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No images available.');
        } else {
          List<Map<String, dynamic>> imagePaths = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: imagePaths.map((imageData) {
                String imagePath = imageData['image_path'];
                String imageUrl = supabase.storage
                    .from('product')
                    .getPublicUrl(imagePath);
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 32) / 3,
                  height: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return const Icon(Icons.error);
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchImagePaths() async {
    try {
      final response = await supabase.from('product').select('image_path');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching image paths: $e');
      return [];
    }
  }
  Row _actionSection({double hPadding = 40}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[

        Visibility(
          visible: !_isOpen,
          child: const SizedBox(
            width: 16,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: _isOpen
                  ? (MediaQuery.of(context).size.width - (2 * hPadding)) / 1.6
                  : double.infinity,
              child: TextButton(
                // Changed FlatButton to TextButton
                onPressed: () => _panelController.open(),
                style: TextButton.styleFrom(
                  // Add style to the button
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: const Text(
                  'Products',
                  style: TextStyle(
                    //fontFamily: 'NimbusSanL',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Info Section
 /* Row _infoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _infoCell(title: 'Projects', value: '1135'),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey,
        ),
        _infoCell(title: 'Hourly Rate', value: "\$65"),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey,
        ),
        _infoCell(title: 'Location', value: 'Dusseldorf'),
      ],
    );
  } */

  /// Info Cell
  /*Column _infoCell({required String title, required String value}) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w300,
            fontSize: 14,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  } */

  /// Title Section
  Column _titleSection() {
    return const Column(
      children: <Widget>[
        Text(
          'View Products',
          style: TextStyle(
            fontFamily: 'NimbusSanL',
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'Slide up or press button to view products!',
          style: TextStyle(
            fontFamily: 'NimbusSanL',
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
