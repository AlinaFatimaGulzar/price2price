import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_bootstrap.dart';

abstract final class ImageBuckets {
  static const carImages = 'car-images';
  static const showroomImages = 'showroom-images';
}

abstract interface class ImageStorageRepository {
  Future<String> uploadImage({
    required String bucket,
    required String folder,
    required Uint8List bytes,
    String? contentType,
    String? fileName,
  });
}

class SupabaseImageStorageRepository implements ImageStorageRepository {
  const SupabaseImageStorageRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<String> uploadImage({
    required String bucket,
    required String folder,
    required Uint8List bytes,
    String? contentType,
    String? fileName,
  }) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    final safeFileName = (fileName ?? 'image.jpg')
        .split(RegExp(r'[^a-zA-Z0-9._-]'))
        .join('_');
    final path =
        '$folder/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';

    await client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType ?? 'image/jpeg',
            cacheControl: '3600',
          ),
        );

    return client.storage.from(bucket).getPublicUrl(path);
  }
}
