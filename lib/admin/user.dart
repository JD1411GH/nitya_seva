class UserDetails {
  String? uid;
  String? name;
  String? phone;
  String? role;

  UserDetails({this.uid, this.name, this.phone, this.role});

  // Convert a UserDetails object into a Map object
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'role': role,
    };
  }

  // Convert a Map object into a UserDetails object
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      uid: json['uid'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
    );
  }
}
