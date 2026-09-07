import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

abstract final class SupabaseBootstrap {
  static Future<void> initialize() async {
    if (!AppConfig.hasSupabaseConfig) return;

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        persistSession: true,
      ),
    );
  }

  static SupabaseClient? get client {
    if (!AppConfig.hasSupabaseConfig) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
