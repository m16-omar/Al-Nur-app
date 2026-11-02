class ApiConstants {
  // Serverpod Cloud backend URL
  static const String defaultServerUrl = 'https://alnur-store.api.serverpod.space/';
  static const String serverHost = 'alnur-store.api.serverpod.space';
  
  // Web & Admin URLs
  static const String webStorefrontUrl = 'https://al-nur-tau.vercel.app';
  static const String adminPortalUrl = 'https://alnur-store.serverpod.space/admin';

  // Request timeouts
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const Duration shortTimeoutDuration = Duration(seconds: 10);

  // Serverpod endpoints
  static const String productEndpoint = 'product';
  static const String categoryEndpoint = 'category';
  static const String orderEndpoint = 'order';
  static const String userEndpoint = 'user';
  static const String emailIdpEndpoint = 'emailIdp';
  static const String aiAssistantEndpoint = 'ai_assistant';
}
