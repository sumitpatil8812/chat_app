import 'dart:convert';

class UserInfo {
  String? uid;
  String? name;
  String? email;

  UserInfo({
    required this.uid,
    required this.name,
    required this.email,
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['uid'] = uid;
    return data;
  }
}
