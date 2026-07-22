import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _keyName = 'secret_recorder_key';
  static const _storage = FlutterSecureStorage();
  static const _keySize = 32;
  static const _ivSize = 12;
  static const _gcmTagSize = 16;

  static Future<Uint8List> _getOrCreateKey() async {
    String? keyBase64 = await _storage.read(key: _keyName);
    if (keyBase64 != null) {
      return Uint8List.fromList(Encrypter(Algorithm('key')).toKey.list);
    }
    
    final key = Key.random(_keySize);
    await _storage.write(key: _keyName, value: key.base64);
    return key.bytes;
  }

  static Future<void> encryptFile(String inputPath, String outputPath) async {
    final keyBytes = await _getOrCreateKey();
    final key = Key(keyBytes);
    final iv = IV.random(_ivSize);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final inputFile = File(inputPath);
    final inputBytes = await inputFile.readAsBytes();
    
    final encrypted = encrypter.encryptBytes(inputBytes, iv: iv);
    
    final outputFile = File(outputPath);
    final output = BytesBuilder();
    output.addByte(iv.bytes.length);
    output.add(iv.bytes);
    output.add(encrypted.bytes);
    
    await outputFile.writeAsBytes(output.toBytes());
  }

  static Future<void> decryptFile(String inputPath, String outputPath) async {
    final keyBytes = await _getOrCreateKey();
    final key = Key(keyBytes);
    
    final inputFile = File(inputPath);
    final inputBytes = await inputFile.readAsBytes();
    
    final ivLength = inputBytes[0];
    final iv = IV(inputBytes.sublist(1, 1 + ivLength));
    final encryptedBytes = inputBytes.sublist(1 + ivLength);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final decrypted = encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
    
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(decrypted);
  }

  static Future<Uint8List> encryptBytes(Uint8List input) async {
    final keyBytes = await _getOrCreateKey();
    final key = Key(keyBytes);
    final iv = IV.random(_ivSize);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final encrypted = encrypter.encryptBytes(input, iv: iv);
    
    final output = BytesBuilder();
    output.addByte(iv.bytes.length);
    output.add(iv.bytes);
    output.add(encrypted.bytes);
    
    return output.toBytes();
  }

  static Future<Uint8List> decryptBytes(Uint8List input) async {
    final keyBytes = await _getOrCreateKey();
    final key = Key(keyBytes);
    
    final ivLength = input[0];
    final iv = IV(input.sublist(1, 1 + ivLength));
    final encryptedBytes = input.sublist(1 + ivLength);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    return encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
  }
}
