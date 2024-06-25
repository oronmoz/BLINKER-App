import 'package:encrypt/encrypt.dart';
import 'encryption_service.dart';

/// Provides functionality for encrypting and decrypting text.
class EncryptionService implements IEncryption {
  final Encrypter _encrypter;
  final _iv = IV.fromLength(16);

  /// Constructs a new [EncryptionService] instance.
  ///
  /// [_encrypter] - The [Encrypter] instance used for the encryption and decryption operations.
  EncryptionService(this._encrypter);

  /// Decrypts the provided encrypted text.
  ///
  /// [encryptedText] - The encrypted text to be decrypted.
  ///
  /// Returns the decrypted text.
  @override
  String decrypt(String? encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText!);
    return _encrypter.decrypt(encrypted, iv: this._iv);
  }

  /// Encrypts the provided plain text.
  ///
  /// [text] - The plain text to be encrypted.
  ///
  /// Returns the encrypted text.
  @override
  String encrypt(String? text) {
    return _encrypter.encrypt(text!, iv: _iv).base64;
  }
}