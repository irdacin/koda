import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:koda/helpers/url_helper.dart';

class ImageService {
  static Future<String?> uploadImage(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse(UrlHelper.urlUploadImage),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${UrlHelper.apiKey}:${UrlHelper.apiSecret}'))}',
      },
      body: {
        'file': 'data:image/png;base64,$base64Image',
        'upload_preset': 'preset-for-file-upload',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['secure_url'];
    }

    return null;
  }

  static Future<Uint8List?> fetchImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    return null;
  }
}
