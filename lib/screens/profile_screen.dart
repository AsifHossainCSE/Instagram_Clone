import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/utilis/colors.dart';
import 'package:instagram_flutter/utilis/utils.dart';
import 'package:instagram_flutter/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length;

      final data = userSnap.data();

      if (data != null) {
        userData = data;

        followers = (data['followers'] ?? []).length;
        following = (data['following'] ?? []).length;

        isFollowing = (data['followers'] ?? [])
            .contains(FirebaseAuth.instance.currentUser?.uid);
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          userData['username']?.toString() ?? 'User',
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      backgroundImage: (userData['photoUrl'] != null &&
                              userData['photoUrl']
                                  .toString()
                                  .isNotEmpty)
                          ? NetworkImage(
                              userData['photoUrl'].toString(),
                            )
                          : null,
                      child: (userData['photoUrl'] == null ||
                              userData['photoUrl']
                                  .toString()
                                  .isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen, "Posts"),
                              buildStatColumn(
                                  followers, "Followers"),
                              buildStatColumn(
                                  following, "Following"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              FirebaseAuth.instance.currentUser?.uid ==
                                      widget.uid
                                  ? FollowButton(
                                      text: 'Sign Out',
                                      backgroundColor:
                                          mobileBackgroundColor,
                                      textColor: primaryColor,
                                      borderColor: Colors.grey,
                                      function: () async {
                                        await FirebaseAuth.instance
                                            .signOut();

                                        if (context.mounted) {
                                          Navigator.of(context)
                                              .pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        }
                                      },
                                    )
                                  : isFollowing
                                      ? FollowButton(
                                          text: 'Unfollow',
                                          backgroundColor:
                                              Colors.white,
                                          textColor: Colors.black,
                                          borderColor:
                                              Colors.grey,
                                          function: () async {
                                            await FireStoreMethods()
                                                .followUser(
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid,
                                              widget.uid,
                                            );

                                            setState(() {
                                              isFollowing =
                                                  false;
                                              followers--;
                                            });
                                          },
                                        )
                                      : FollowButton(
                                          text: 'Follow',
                                          backgroundColor:
                                              Colors.blue,
                                          textColor:
                                              Colors.white,
                                          borderColor:
                                              Colors.blue,
                                          function: () async {
                                            await FireStoreMethods()
                                                .followUser(
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid,
                                              widget.uid,
                                            );

                                            setState(() {
                                              isFollowing =
                                                  true;
                                              followers++;
                                            });
                                          },
                                        ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    userData['username']?.toString() ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    userData['bio']?.toString() ?? '',
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('posts')
                .where('uid', isEqualTo: widget.uid)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 1.5,
                ),
                itemBuilder: (context, index) {
                  DocumentSnapshot snap =
                      snapshot.data!.docs[index];

                  return Image.network(
                    snap['postUrl']?.toString() ?? '',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.error),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}