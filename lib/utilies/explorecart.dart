import 'package:flutter/material.dart';
import 'package:agrismart/color.dart';

class ExploreCart extends StatelessWidget {

  final String image;
  final String name;
  final String subname;
  final String userimage;
  final String username;

  final double rating;

  const ExploreCart({
    super.key,
    required this.image,
    required this.name,
    required this.subname,
    required this.userimage,
    required this.username,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Stack(
        children: [
          SizedBox(
            height: 130,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  height: 130,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          height: 120,
                          width: 110,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              image: DecorationImage(
                                // Use NetworkImage for the main image
                                  image: NetworkImage(
                                    image,
                                  ),
                                  fit: BoxFit.cover)),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, left: 8),
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            subname,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: inActiveColor,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.more_vert)
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      // Use NetworkImage for the user image
                                      backgroundImage: NetworkImage(userimage),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            username,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: textColor),
                                          ),
                                          const Text(
                                            "Nutrition",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: labelColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              right: 10,
              bottom: 20,
              child: Container(
                height: 25,
                width: 50,
                decoration: BoxDecoration(
                    color: primary, borderRadius: BorderRadius.circular(6)),
                child: Center( // Remove const here as the Text widget will be dynamic
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 15,
                        color: Colors.black,
                      ),
                      // Display the rating fetched from Supabase
                      Text(rating.toStringAsFixed(1)) // Format the double to one decimal place
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}