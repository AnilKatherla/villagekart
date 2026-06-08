class AuthResponseModel {
  final bool status;
  final String response;
  final AuthData data;

  AuthResponseModel({
    required this.status,
    required this.response,
    required this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: AuthData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'response': response,
      'data': data.toJson(),
    };
  }
}

class AuthData {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  AuthData({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: UserModel.fromJson(json['user'] ?? {}),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String role;
  final String? avatar;
  final bool isProfileComplete;
  final List<String> missingFields;
  final bool isNewUser;

  UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    required this.role,
    this.avatar,
    required this.isProfileComplete,
    required this.missingFields,
    required this.isNewUser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'CONSUMER',
      avatar: json['avatar'],
      isProfileComplete: json['isProfileComplete'] ?? false,
      missingFields: List<String>.from(json['missingFields'] ?? []),
      isNewUser: json['isNewUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'isProfileComplete': isProfileComplete,
      'missingFields': missingFields,
      'isNewUser': isNewUser,
    };
  }

  // ✅ Copy with method (useful for updates)
  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? role,
    String? avatar,
    bool? isProfileComplete,
    List<String>? missingFields,
    bool? isNewUser,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      missingFields: missingFields ?? this.missingFields,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}