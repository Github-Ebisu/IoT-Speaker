class UserModels {
  final String uid;
  final String? email;

  UserModels({
    required this.uid,
    required this.email,
  });
}

class UserData {
  final String email;
  final String userName;

  UserData({
    required this.email,
    required this.userName,
  });

  factory UserData.fromRTDB(Map<dynamic, dynamic> data) {
    return UserData(
      email: data["email"] as String? ?? '',
      userName: data["userName"] as String? ?? '',
    );
  }

  factory UserData.empty() {
    return UserData(
      email: "None",
      userName: "None",
    );
  }
}
