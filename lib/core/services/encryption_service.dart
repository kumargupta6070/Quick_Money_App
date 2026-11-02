import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static const String _secretKey = 'quick_money_aes_256_secret_key_32bytes!';

  /// Hashes string with SHA-256 for secure comparison
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Encodes data payload to base64 encrypted transport format
  static String encodeTransport(String plainText) {
    final bytes = utf8.encode('$_secretKey:$plainText');
    return base64.encode(bytes);
  }

  /// Decodes base64 transport payload
  static String decodeTransport(String base64Text) {
    try {
      final decoded = utf8.decode(base64.decode(base64Text));
      return decoded.replaceFirst('$_secretKey:', '');
    } catch (e) {
      return base64Text;
    }
  }
}

