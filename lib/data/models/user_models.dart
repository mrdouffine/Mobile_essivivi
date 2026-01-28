/// User-related data models matching the Django backend structure

class CustomUser {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;

  CustomUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.firstName,
    this.lastName,
  });

  factory CustomUser.fromJson(Map<String, dynamic> json) {
    return CustomUser(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  bool get isAgent => role == 'agent';
  bool get isClient => role == 'client';
  bool get isAdmin => role == 'admin';
  bool get isGestionnaire => role == 'gestionnaire';
}

class AgentProfile {
  final int id;
  final int userId;
  final String? photo;
  final String? dateEmbauche;
  final int? tricycleId;
  final String? zoneAssignee;
  final double? latitude;
  final double? longitude;
  final String? identificationNumber;
  final String? tricyclePlate;
  
  // Nested user object if included in response
  final CustomUser? user;

  // Added getters for UI fields
  String get vehicleType => tricycleId != null ? 'Standard' : '...';
  String get licensePlate => tricyclePlate ?? '...';

  AgentProfile({
    required this.id,
    required this.userId,
    this.photo,
    this.dateEmbauche,
    this.tricycleId,
    this.zoneAssignee,
    this.latitude,
    this.longitude,
    this.identificationNumber,
    this.tricyclePlate,
    this.user,
  });

  factory AgentProfile.fromJson(Map<String, dynamic> json) {
    return AgentProfile(
      id: json['id'] as int,
      userId: json['user'] is int ? json['user'] as int : (json['user'] as Map<String, dynamic>)['id'] as int,
      photo: json['photo'] as String?,
      dateEmbauche: json['date_embauche'] as String?,
      tricycleId: json['tricycle'] as int?,
      zoneAssignee: json['zone_assignee'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      identificationNumber: json['identification_number'] as String?,
      tricyclePlate: json['tricycle_plate'] as String?,
      user: json['user'] is Map<String, dynamic> ? CustomUser.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'photo': photo,
      'date_embauche': dateEmbauche,
      'tricycle': tricycleId,
      'zone_assignee': zoneAssignee,
      'latitude': latitude,
      'longitude': longitude,
      'identification_number': identificationNumber,
      'tricycle_plate': tricyclePlate,
    };
  }

  bool get hasLocation => latitude != null && longitude != null;
}

class ClientProfile {
  final int id;
  final int userId;
  final String nomPointVente;
  final String? nomProprietaire;
  final String? adresse;
  final double? gpsLat;
  final double? gpsLng;
  final double solde;
  
  // Nested user object if included in response
  final CustomUser? user;

  ClientProfile({
    required this.id,
    required this.userId,
    required this.nomPointVente,
    this.nomProprietaire,
    this.adresse,
    this.gpsLat,
    this.gpsLng,
    required this.solde,
    this.user,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: json['id'] as int,
      userId: json['user'] is int ? json['user'] as int : (json['user'] as Map<String, dynamic>)['id'] as int,
      nomPointVente: json['nom_point_vente'] as String,
      nomProprietaire: json['nom_proprietaire'] as String?,
      adresse: json['adresse'] as String?,
      gpsLat: json['gps_lat'] != null ? (json['gps_lat'] as num).toDouble() : null,
      gpsLng: json['gps_lng'] != null ? (json['gps_lng'] as num).toDouble() : null,
      solde: (json['solde'] as num).toDouble(),
      user: json['user'] is Map<String, dynamic> ? CustomUser.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'nom_point_vente': nomPointVente,
      'nom_proprietaire': nomProprietaire,
      'adresse': adresse,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
      'solde': solde,
    };
  }

  bool get hasLocation => gpsLat != null && gpsLng != null;
}

/// Login request model
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

/// Login response model
class LoginResponse {
  final String access;
  final String refresh;

  LoginResponse({
    required this.access,
    required this.refresh,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }
}

/// Signup request model
class SignupRequest {
  final String username;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;

  SignupRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
