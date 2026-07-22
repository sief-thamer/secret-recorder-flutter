import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _keyName = 'secret_recorder_key';
  static const _storage = FlutterSecureStorage();

  static Future<Uint8List> _getKey() async {
    String? k = await _storage.read(key: _keyName);
    if (k != null) return Key.fromBase64(k).bytes;
    final key = Key.random(32);
    await _storage.write(key: _keyName, value: key.base64);
    return key.bytes;
  }

  static Future<void> encryptFile(String inp, String out) async {
    final key = Key(await _getKey());
    final iv = IV.random(12);
    final enc = Encrypter(AES(key, mode: AESMode.gcm));
    final data = await File(inp).readAsBytes();
    final encrypted = enc.encryptBytes(data, iv: iv);
    final buf = BytesBuilder()..addByte(iv.bytes.length)..add(iv.bytes)..add(encrypted.bytes);
    await File(out).writeAsBytes(buf.toBytes());
  }

  static Future<void> decryptFile(String inp, String out) async {
    final key = Key(await _getKey());
    final data = await File(inp).readAsBytes();
    final ivLen = data[0];
    final iv = IV(data.sublist(1, 1 + ivLen));
    final enc = Encrypter(AES(key, mode: AESMode.gcm));
    final dec = enc.decryptBytes(Encrypted(data.sublist(1 + ivLen)), iv: iv);
    await File(out).writeAsBytes(dec);
  }
}