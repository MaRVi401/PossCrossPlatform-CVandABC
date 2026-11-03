class UserModel {
  final int userId;
  final int roleId;
  final String roleName;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? accessToken;

  UserModel({
    required this.userId,
    required this.roleId,
    required this.roleName,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      userId: json['user_id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      roleName: json['role_name'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      accessToken: token ?? json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role_id': roleId,
      'role_name': roleName,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'access_token': accessToken,
    };
  }
}