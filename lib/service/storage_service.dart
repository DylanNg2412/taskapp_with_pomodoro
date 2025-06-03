import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class StorageService {
  static final _instance = StorageService.init();
  StorageService.init();
  factory StorageService() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<void> uploadImage(String name, Uint8List bytes) async {
    final resp = await supabase.storage
        .from("images")
        .uploadBinary(name, bytes, fileOptions: FileOptions(upsert: true));
    debugPrint("Upload image response: $resp");
  }

  Future<Uint8List?> getImage(String name) async {
    final url = await supabase.storage.from("images").getPublicUrl(name);
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      return null;
    }
    return resp.bodyBytes;
  }
}
