import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

abstract final class SupabaseBootstrap {
  static Future<void> initialize() async {
    if (!AppConfig.hasSupabaseConfig) return;

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }

  static SupabaseClient? get client {
    if (!AppConfig.hasSupabaseConfig) return null;
    return Supabase.instance.client;
  }
}
