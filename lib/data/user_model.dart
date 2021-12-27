class UserModel {
  late String phone;
  late String uId;

  UserModel({
    required this.phone,
    required this.uId,
  });

  UserModel.fromJson(Map<String, dynamic>? json) {
    phone = json!['phone'];
    uId = json['uId'];
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'uId': uId,
    };
  }
}
