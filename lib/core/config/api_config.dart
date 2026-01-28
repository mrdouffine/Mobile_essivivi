/// API Configuration Constants
class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://essivi-backend.onrender.com/api';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String signupEndpoint = '/auth/signup/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String meEndpoint = '/users/me/';
  static const String tokenRefreshEndpoint = '/token/refresh/';
  static const String changePasswordEndpoint = '/auth/change-password/';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String isAuthenticatedKey = 'is_authenticated';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';

  // Sales Endpoints
  static const String commandesEndpoint = '/sales/commandes/';
  static const String livraisonsEndpoint = '/sales/livraisons/';
  static const String agentRatingsEndpoint = '/sales/agent-ratings/';
  
  // Logistics Endpoints
  static const String tourneesEndpoint = '/logistics/tournees/';
  static const String agentsEndpoint = '/users/agents/';
  
  // User Endpoints
  static const String clientsEndpoint = '/users/clients/';
  static const String usersEndpoint = '/users/users/';
  
  // Subscription Endpoints
  static const String subscriptionsEndpoint = '/subscriptions/subscriptions/';
  
  // Bottle Return Endpoints
  static const String bottleReturnsEndpoint = '/bottle-returns/returns/';
  
  // Support Endpoints
  static const String faqEndpoint = '/support/faq/';
  static const String supportTicketsEndpoint = '/support/tickets/';
  
  // Notification Endpoints
  static const String notificationsEndpoint = '/notifications/';
  
  // Preferences Endpoints
  static const String preferencesEndpoint = '/preferences/';
  
  // WebSocket
  static const String wsBaseUrl = 'wss://essivi-backend.onrender.com/ws';
}

/// Environment Configuration
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment current = Environment.development;
  
  static String get baseUrl {
    switch (current) {
      case Environment.development:
        return 'https://essivi-backend.onrender.com/api';
      case Environment.staging:
        return 'https://staging.essivi.com/api';
      case Environment.production:
        return 'https://api.essivi.com/api';
    }
  }
  
  static String get wsBaseUrl {
    switch (current) {
      case Environment.development:
        return 'wss://essivi-backend.onrender.com/ws';
      case Environment.staging:
        return 'wss://staging.essivi.com/ws';
      case Environment.production:
        return 'wss://api.essivi.com/ws';
    }
  }
}
