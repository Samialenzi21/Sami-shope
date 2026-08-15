class AppConfig {
  const AppConfig._();

  static const String medusaBaseUrl = String.fromEnvironment(
    'MEDUSA_BASE_URL',
  );

  static const String medusaPublishableKey = String.fromEnvironment(
    'MEDUSA_PUBLISHABLE_KEY',
  );
}
