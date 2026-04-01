enum Environment { development, staging, production }

class EnvConfig {
  final Environment environment;
  final String baseUrl;
  final String apiKey;

  const EnvConfig({
    required this.environment,
    required this.baseUrl,
    required this.apiKey,
  });

  static const EnvConfig development = EnvConfig(
    environment: Environment.development,
    baseUrl: 'http://192.168.43.215:3000/api',
    apiKey: 'dev-api-key',
  );

  static const EnvConfig staging = EnvConfig(
    environment: Environment.staging,
    baseUrl: 'http://192.168.43.215:3000/api',
    apiKey: 'staging-api-key',
  );

  // static const EnvConfig production = EnvConfig(
  //   environment: Environment.production,
  //   baseUrl: 'https://api.smartspent.com/v1',
  //   apiKey: 'prod-api-key',
  // );

  bool get isDevelopment => environment == Environment.development;
  bool get isProduction => environment == Environment.production;
}
