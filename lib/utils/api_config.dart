import 'dart:io';
/// API Configuration for Essivi Mobile App
/// 
/// This file contains all API-related configuration settings.
/// Update the baseUrl based on your environment:
/// - For Android Emulator: http://10.0.2.2:8000/api
/// - For iOS Simulator: http://localhost:8000/api
/// - For Physical Device: http://YOUR_MACHINE_IP:8000/api (e.g., http://192.168.1.100:8000/api)

class ApiConfig {
  // ⚠️ PRODUCTION: Mettre à true avant déploiement
  static const bool isProduction = false;
  
  // Base URL for the API
  static const String _prodUrl = 'https://api.essivivi.com/api'; // TODO: Mettre votre URL de production
  
  static String get baseUrl {
    if (isProduction) return _prodUrl;
    
    // En développement, utiliser Traefik (port 80)
    // Android Emulator: 10.0.2.2:8081
    // iOS/Desktop: localhost:8081
    if (Platform.isAndroid) {
      return 'https://essivi-backend.onrender.com/api';
    }
    return 'https://essivi-backend.onrender.com/api';
  }

  static String get wsUrl {
    // WebSocket via Traefik
    if (isProduction) {
      return _prodUrl.replaceFirst('https', 'wss').replaceFirst('/api', '/ws/notifications/');
    }
    
    if (Platform.isAndroid) {
      return 'wss://essivi-backend.onrender.com/ws/notifications/';
    }
    return 'wss://essivi-backend.onrender.com/ws/notifications/';
  }
  
  // Alternative URLs for different environments
  static const String localUrl = 'https://essivi-backend.onrender.com/api';  // Via Traefik
  static const String productionUrl = 'https://api.essivivi.com/api'; // Update with actual production URL
  
  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
  
  // API Endpoints
  static const String tokenEndpoint = '/token/';
  static const String tokenRefreshEndpoint = '/token/refresh/';
  
  // Users endpoints
  static const String usersEndpoint = '/users/users/';
  static const String agentsEndpoint = '/users/agents/';
  static const String clientsEndpoint = '/users/clients/';
  static const String meEndpoint = '/users/me/';
  static const String loginEndpoint = '/users/auth/login/';
  static const String signupEndpoint = '/users/auth/signup/';
  static const String logoutEndpoint = '/users/auth/logout/';
  
  // Logistics endpoints
  static const String tricyclesEndpoint = '/logistics/tricycles/';
  static const String tourneesEndpoint = '/logistics/tournees/';
  
  // Sales endpoints
  static const String commandesEndpoint = '/sales/commandes/';
  static const String livraisonsEndpoint = '/sales/livraisons/';
  
  // Dashboard endpoints
  static const String dashboardStatsEndpoint = '/dashboard/stats/';
  
  // Notifications endpoints
  static const String notificationsEndpoint = '/sales/notifications/';
  static const String markNotificationReadEndpoint = '/sales/notifications/{id}/mark_read/';
  static const String markAllNotificationsReadEndpoint = '/sales/notifications/mark_all_read/';
  
  // Bottle returns endpoints
  static const String bottleReturnsEndpoint = '/sales/bottle-returns/';
  
  // User preferences endpoints
  static const String preferencesEndpoint = '/users/preferences/';
  
  // Abonnements endpoints
  static const String subscriptionsEndpoint = '/sales/subscriptions/';
  
  // FAQs endpoints
  static const String faqsEndpoint = '/sales/faqs/';
  
  // Change password endpoint
  static const String changePasswordEndpoint = '/users/auth/change-password/';
  
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  static const String isAuthenticatedKey = 'is_authenticated';
}

