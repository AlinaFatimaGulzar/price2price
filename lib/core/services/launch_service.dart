import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles external app launches (phone calls, WhatsApp, email, maps).
///
/// Abstract so UI stays testable: production uses [UrlLaunchService],
/// tests substitute a fake that records the requested actions.
abstract interface class LaunchService {
  Future<bool> call(String phoneNumber);
  Future<bool> whatsApp({required String phoneNumber, String? message});
  Future<bool> mailTo({required String email, String? subject});
  Future<bool> openMap(
    String address, {
    String? city,
    double? latitude,
    double? longitude,
  });
}

class UrlLaunchService implements LaunchService {
  const UrlLaunchService();

  /// Normalizes a phone number for `tel:` links. Pakistian numbers are
  /// assumed: `03XXXXXXXXX` → `+92XXXXXXXXX`. A leading `+` is kept as-is.
  @visibleForTesting
  static String normalizePhoneForCall(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('+')) return digits;
    final withoutLeadingZero = digits.startsWith('0')
        ? digits.substring(1)
        : (digits.startsWith('92') ? digits.substring(2) : digits);
    return '+92$withoutLeadingZero';
  }

  /// Normalizes a phone number for `https://wa.me/` links: digits only,
  /// national leading zero dropped, `+` removed (e.g. `03001234567` →
  /// `923001234567`). Returns `''` when nothing can be parsed.
  @visibleForTesting
  static String normalizePhoneForWhatsApp(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('0')) return '92${digits.substring(1)}';
    if (digits.startsWith('92')) return digits;
    return '92$digits';
  }

  @override
  Future<bool> call(String phoneNumber) async {
    final number = normalizePhoneForCall(phoneNumber);
    if (number.isEmpty) return false;
    final uri = Uri(scheme: 'tel', path: number);
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Future<bool> whatsApp({required String phoneNumber, String? message}) async {
    final waNumber = normalizePhoneForWhatsApp(phoneNumber);
    if (waNumber == '0') return false;
    final query = message == null ? null : {'text': message};
    final uri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: waNumber,
      queryParameters: query,
    );
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Future<bool> mailTo({required String email, String? subject}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: subject == null ? null : {'subject': subject},
    );
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Future<bool> openMap(
    String address, {
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    final query = switch ((latitude, longitude)) {
      (final double lat, final double lng) => '$lat,$lng',
      _ => [
        address,
        city,
      ].whereType<String>().where((s) => s.trim().isNotEmpty).join(', '),
    };
    if (query.trim().isEmpty) return false;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${Uri.encodeComponent(query)}',
    );
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
