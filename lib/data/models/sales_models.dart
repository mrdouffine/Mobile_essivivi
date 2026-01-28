/// Sales-related data models matching the Django backend structure

class Commande {
  final int id;
  final int clientId;
  final int? agentId;
  final String statut;
  final double montant;
  final String dateSouhaitee;
  final String createdAt;
  final String updatedAt;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? clientPhone;
  final String? agentPhone;

  Commande({
    required this.id,
    required this.clientId,
    this.agentId,
    required this.statut,
    required this.montant,
    required this.dateSouhaitee,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.clientPhone,
    this.agentPhone,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as int,
      clientId: json['client'] as int,
      agentId: json['agent'] as int?,
      statut: json['statut'] as String,
      montant: double.parse(json['montant'].toString()),
      dateSouhaitee: json['date_souhaitee'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deliveryLatitude: json['delivery_latitude'] != null ? double.tryParse(json['delivery_latitude'].toString()) : null,
      deliveryLongitude: json['delivery_longitude'] != null ? double.tryParse(json['delivery_longitude'].toString()) : null,
      clientPhone: json['client_phone'] as String?,
      agentPhone: json['agent_phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': clientId,
      'agent': agentId,
      'statut': statut,
      'montant': montant,
      'date_souhaitee': dateSouhaitee,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
    };
  }

  // Getter pour compatibilité
  int? get agent => agentId;

  bool get isPending => statut == 'pending';
  bool get isValidated => statut == 'validated';
  bool get isDelivered => statut == 'delivered';
  bool get isCancelled => statut == 'cancelled';

  String get statutLabel {
    switch (statut) {
      case 'pending':
        return 'En attente';
      case 'validated':
        return 'Validée';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return statut;
    }
  }
}

class Livraison {
  final int id;
  final int tourneeId;
  final int? commandeId;
  final int clientId;
  final String? statutLivraison;
  final double? gpsLat;
  final double? gpsLng;
  final String? photoPreuve;
  final String? signature;
  final bool preuveValidee;
  final String timestamp;
  final String? clientPhone;
  final String? agentPhone;

  // Added getters for UI compatibility
  bool get isDelivered => preuveValidee;
  String get createdAt => timestamp;
  
  // Status helpers
  bool get isAssigned => statutLivraison == 'assigned';
  bool get isEnRoute => statutLivraison == 'en_route';
  bool get isArriving => statutLivraison == 'arriving';

  Livraison({
    required this.id,
    required this.tourneeId,
    this.commandeId,
    required this.clientId,
    this.statutLivraison,
    this.gpsLat,
    this.gpsLng,
    this.photoPreuve,
    this.signature,
    required this.preuveValidee,
    required this.timestamp,
    this.clientPhone,
    this.agentPhone,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      id: json['id'] as int,
      tourneeId: json['tournee'] as int,
      commandeId: json['commande'] as int?,
      clientId: json['client'] as int,
      statutLivraison: json['statut_livraison'] as String? ?? 'assigned',
      gpsLat: json['gps_lat'] != null ? (json['gps_lat'] as num).toDouble() : null,
      gpsLng: json['gps_lng'] != null ? (json['gps_lng'] as num).toDouble() : null,
      photoPreuve: json['photo_preuve'] as String?,
      signature: json['signature'] as String?,
      preuveValidee: json['preuve_validee'] as bool? ?? false,
      timestamp: json['timestamp'] as String,
      clientPhone: json['client_phone'] as String?,
      agentPhone: json['agent_phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournee': tourneeId,
      'commande': commandeId,
      'client': clientId,
      'statut_livraison': statutLivraison,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
      'photo_preuve': photoPreuve,
      'signature': signature,
      'preuve_validee': preuveValidee,
      'timestamp': timestamp,
    };
  }

  bool get hasLocation => gpsLat != null && gpsLng != null;
  bool get hasProof => photoPreuve != null;
  bool get hasSignature => signature != null;
  bool get isComplete => hasLocation && hasProof && hasSignature;
}

/// Create Commande request model
class CreateCommandeRequest {
  final int clientId;
  final double montant;
  final String dateSouhaitee;
  final int? agentId;
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  CreateCommandeRequest({
    required this.clientId,
    required this.montant,
    required this.dateSouhaitee,
    this.agentId,
    this.deliveryLatitude,
    this.deliveryLongitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'client': clientId,
      'montant': montant,
      'date_souhaitee': dateSouhaitee,
      'agent': agentId,
      'statut': 'pending',
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
    };
  }
}

/// Update Commande request model
class UpdateCommandeRequest {
  final String? statut;
  final int? agentId;

  UpdateCommandeRequest({
    this.statut,
    this.agentId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (statut != null) data['statut'] = statut;
    if (agentId != null) data['agent'] = agentId;
    return data;
  }
}

/// Create Livraison request model
/// Note: For file uploads, use FormData with multipart
class CreateLivraisonRequest {
  final int tourneeId;
  final int clientId;
  final int? commandeId;
  final double? gpsLat;
  final double? gpsLng;

  CreateLivraisonRequest({
    required this.tourneeId,
    required this.clientId,
    this.commandeId,
    this.gpsLat,
    this.gpsLng,
  });

  Map<String, dynamic> toJson() {
    return {
      'tournee': tourneeId,
      'client': clientId,
      'commande': commandeId,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
    };
  }
}

class AgentRating {
  final int id;
  final int commandeId;
  final int agentId;
  final int rating;
  final String? comment;
  final String createdAt;

  AgentRating({
    required this.id,
    required this.commandeId,
    required this.agentId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory AgentRating.fromJson(Map<String, dynamic> json) {
    return AgentRating(
      id: json['id'] as int,
      commandeId: json['commande'] as int,
      agentId: json['agent'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commande': commandeId,
      'agent': agentId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
    };
  }
}
