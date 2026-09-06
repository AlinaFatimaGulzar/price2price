abstract final class AppConfig {
  static const _defaultSupabaseUrl = 'https://ozvxovlwwctwbiwcfdfy.supabase.co';
  static const _defaultSupabasePublishableKey =
      'sb_publishable_Yg61yWR4ix_kGGEVGEeHgg_wL_rFIBT';

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultSupabaseUrl,
  );
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: _defaultSupabasePublishableKey,
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
