import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;

  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
  });

  // ✅ SAFE FIRESTORE PARSER (FIXED)
  static User fromSnap(DocumentSnapshot snap) {
    final data = snap.data();

    if (data == null) {
      throw Exception("❌ User document does not exist in Firestore");
    }

    final snapshot = data as Map<String, dynamic>;

    return User(
      username: snapshot["username"] ?? "",
      uid: snapshot["uid"] ?? "",
      email: snapshot["email"] ?? "",
      photoUrl: snapshot["photoUrl"] ?? "",
      bio: snapshot["bio"] ?? "",
      followers: List.from(snapshot["followers"] ?? []),
      following: List.from(snapshot["following"] ?? []),
    );
  }

  // ✅ Convert model → Firestore
  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "uid": uid,
      "email": email,
      "photoUrl": photoUrl,
      "bio": bio,
      "followers": followers,
      "following": following,
    };
  }
}