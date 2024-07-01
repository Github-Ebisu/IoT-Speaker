import 'package:firebase_database/firebase_database.dart';
import 'package:spotifour/models/song.dart';
import 'package:spotifour/models/user.dart';

import '../models/control_signal.dart';

class RealTimeDBService {
  final _database = FirebaseDatabase.instance.ref();
  final String uid;

  RealTimeDBService({this.uid = ""});

  Future updateUserData(String email, String password, String userName) async {
    try {
      final userData = <String, dynamic>{
        "email": email,
        "password": password,
        "userName": userName,
      };
      await _database.child('UserAccount/$uid').update(userData);
    } catch (e) {
      print("Error update user data : $e");
    }
  }

  Stream<UserData> getUserStream() {
    final userStream = _database.child('UserAccount/$uid').onValue;
    final streamToPublish = userStream.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map<dynamic, dynamic>) {
        // Return a default UserData object if data is null or not a map
        return UserData.empty();
      }
      final userMap = Map<String, dynamic>.from(data);
      return UserData.fromRTDB(userMap);
    });
    return streamToPublish;
  }

  // Stream<List<Song>> getSongsStream() {
  //   final songStream = _database.child('Songs').onValue;
  //   final streamToPublish = songStream.map((event) {
  //     final songsMap = event.snapshot.value as Map<dynamic, dynamic>;
  //     final allSongs = songsMap.values.expand((subMap) {
  //       final songSubMap = subMap as Map<dynamic, dynamic>;
  //       return songSubMap.values.map((songData) {
  //         return Song.fromRTDB(Map<dynamic, dynamic>.from(songData));
  //       });
  //     }).toList();
  //     return allSongs;
  //   });
  //   return streamToPublish;
  // }

  Stream<List<Song>> getSongsStream() {
    final songStream = _database.child('Songs').onValue;
    final streamToPublish = songStream.map((event) {
      final songsMap = event.snapshot.value as Map<dynamic, dynamic>;
      final allSongs = songsMap.values.map((songData) {
        return Song.fromRTDB(Map<String, dynamic>.from(songData));
      }).toList();
      return allSongs;
    });
    return streamToPublish;
  }

  Future<void> updateOnceControlSignal(String field, dynamic value) async {
    try {
      await _database.child('Control/ESP_Sub').update({field: value});
    } catch (e) {
      print("Error update control : $e");
    }
  }

  Future<dynamic> getControl(String field) async {
    try {
      final snapshot = await _database.child('Control/ESP_Sub/$field').get();
      if (snapshot.exists) {
        return snapshot.value;
      } else {
        print('No data available.');
        return null;
      }
    } catch (e) {
      print("Error update control : $e");
      return null;
    }
  }

  Future<void> updateMultipleControlSignals(dynamic value) async {
    try {
      final control = <String, dynamic>{
        'play': value.play,
        'songID': value.songID,
      };
      await _database.child('Control/ESP_Sub').update(control);
    } catch (e) {
      print("Error update control : $e");
    }
  }

  Future<void> updateSuccess(String field, dynamic value) async {
    try {
      await _database.child('Control/ESP_Pub').update({field: value});
    } catch (e) {
      print("Error update control : $e");
    }
  }

  Future<void> resetControl() async {
    final control = <String, dynamic>{
      "finished": false,
      "play": false,
      "songID": 0,
      "stop": false,
    };
    try {
      await _database.child('Control/ESP_Sub').update(control);
    } catch (e) {
      print("Error reset control : $e");
    }
  }

  //
  // // Get AdminData doc stream
  // Stream<AdminData> get adminData {
  //   return adminCollection.doc(uid).snapshots().map(_adminDataFromSnapshot);
  // }
  //
  // // adminData from snapshot
  // AdminData _adminDataFromSnapshot(DocumentSnapshot snapshot) {
  //   return AdminData(
  //     uid: uid,
  //     email: snapshot.get("email"),
  //     password: snapshot.get("password"),
  //     avatar: snapshot.get("avatar"),
  //     adminName: snapshot.get("adminName"),
  //     parkingFee: snapshot.get("parkingFee"),
  //     carSlot: snapshot.get("carSlot"),
  //     revenue: snapshot.get("revenue"),
  //     updatingStatus: snapshot.get("updateRFIDStatus.updatingStatus") ?? false,
  //     carPassengerCount: snapshot.get("carPassengerCount"),
  //   );
  // }

  //   Future updateAdminField(String field, dynamic value) async {
  //     return await adminCollection.doc(uid).update({field: value});
  //   }
}
