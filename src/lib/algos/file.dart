import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:archive/archive.dart';

/// Reads the file at [path] and returns its content as a [String].
/// 
/// This function uses a stream to decode the file in UTF-8 and join
/// the chunks, which is more efficient for handling large files.
Future<String> readFile(String path) async {
  final file = File(path);
  // Open a stream and decode as UTF8
  return file
      .openRead()
      .transform(utf8.decoder)
      .join();
}

/// Saves the given [data] as a string to the file at [path].
/// 
/// This writes the file in an asynchronous and efficient way.
Future<void> saveFile(String path, String data) async {
  final file = File(path);
  await file.writeAsString(data, flush: true);
}

/// Reads a JSON file from [path] and returns its contents as a [Map<String, dynamic>].
Future<Map<String, dynamic>> readJSON(String path) async {
  final contents = await readFile(path);
  return jsonDecode(contents) as Map<String, dynamic>;
}

/// Saves the JSON [jsonObject] to the file at [path].
Future<void> saveJSON(String path, Map<String, dynamic> jsonObject) async {
  final jsonString = jsonEncode(jsonObject);
  await saveFile(path, jsonString);
}

/// Hashes the provided [input] string using SHA-256 and returns the hexadecimal digest.
String hashString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Encrypts the file at [path] using AES encryption (CBC mode with PKCS7 padding)
/// with the provided [password]. The key is derived from the password using SHA-256.
///
/// The resulting encrypted data is saved back to the file in JSON format:
/// {
///   "cipher": "AES",
///   "cipher data": "<iv>:<ciphertext>",
///   "encrypted by": "karNOTE"
/// }
Future<void> encryptFile(String path, String password) async {
  // Read the file's plaintext.
  final plainText = await readFile(path);

  // Derive a 256-bit key from the password using SHA-256.
  final keyBytes = sha256.convert(utf8.encode(password)).bytes;
  final key = encrypt.Key(Uint8List.fromList(keyBytes));

  // Generate a random 16-byte IV.
  final iv = encrypt.IV.fromSecureRandom(16);

  // Create an AES encrypter in CBC mode.
  final encrypter = encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc),
  );

  // Encrypt the plaintext.
  final encryptedData = encrypter.encrypt(plainText, iv: iv);

  // Format the cipher data as "iv:ciphertext" (both in base64).
  final cipherData = '${iv.base64}:${encryptedData.base64}';

  // Create the JSON object to store the encrypted file.
  final jsonObject = {
    'cipher': 'AES',
    'cipher data': cipherData,
    'encrypted by': 'karNOTE',
  };

  // Save the JSON back to the file.
  await saveJSON(path, jsonObject);
}

/// Decrypts the AES‑encrypted file at [path] using the provided [password].
///
/// The file must be in the JSON format produced by [encryptFile]. On successful
/// decryption, the file is overwritten with the decrypted plain text.
Future<void> decryptFile(String path, String password) async {
  // Read the encrypted JSON from the file.
  final jsonObject = await readJSON(path);

  // Verify that the cipher is supported.
  if (jsonObject['cipher'] != 'AES') {
    throw Exception('Unsupported cipher: ${jsonObject['cipher']}');
  }

  // Extract and split the cipher data into IV and ciphertext.
  final cipherDataStr = jsonObject['cipher data'] as String;
  final parts = cipherDataStr.split(':');
  if (parts.length != 2) {
    throw Exception('Invalid cipher data format.');
  }
  final ivBase64 = parts[0];
  final cipherTextBase64 = parts[1];

  // Derive the key from the password.
  final keyBytes = sha256.convert(utf8.encode(password)).bytes;
  final key = encrypt.Key(Uint8List.fromList(keyBytes));

  // Recreate the IV from its base64 representation.
  final iv = encrypt.IV.fromBase64(ivBase64);

  // Create the AES encrypter.
  final encrypter = encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc),
  );

  // Decrypt the ciphertext.
  final decrypted = encrypter.decrypt64(cipherTextBase64, iv: iv);

  // Save the decrypted plain text back to the file.
  await saveFile(path, decrypted);
}

/// Compresses (zips) the file at [path] and saves it as a .zip file in the same directory.
/// 
/// The resulting zip file will have the same name as the original file with an added '.zip' extension.
Future<void> zipFile(String path) async {
  final file = File(path);
  final fileBytes = await file.readAsBytes();
  final fileName = file.uri.pathSegments.last;

  // Create an archive and add the file to it.
  final archive = Archive();
  archive.addFile(ArchiveFile(fileName, fileBytes.length, fileBytes));

  // Encode the archive as zip.
  final zipData = ZipEncoder().encode(archive);

  // Write the zip file to disk (e.g., "example.txt.zip").
  final zipPath = '$path.zip';
  final zipFileOut = File(zipPath);
  await zipFileOut.writeAsBytes(zipData, flush: true);
}

/// Extracts (unzips) the .zip file at [path] into its containing directory.
/// 
/// If the zip archive contains directories or multiple files, they will be
/// extracted preserving the original structure.
Future<void> unzipFile(String path) async {
  final zipFile = File(path);
  final bytes = await zipFile.readAsBytes();

  // Decode the zip archive.
  final archive = ZipDecoder().decodeBytes(bytes);

  // Get the directory where the zip file is located.
  final dir = zipFile.parent;

  // Iterate over the files in the archive.
  for (final file in archive) {
    final filename = file.name;
    final filePath = '${dir.path}/$filename';

    if (file.isFile) {
      // Create and write the file.
      final outFile = File(filePath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>, flush: true);
    } else {
      // Create a directory.
      final directory = Directory(filePath);
      await directory.create(recursive: true);
    }
  }
}


/// Deletes the file specified by [file].
/// 
/// If the file exists, it will be deleted asynchronously.
/// Throws an exception if the file does not exist or deletion fails.
Future<void> deleteFile(File file) async {
  if (await file.exists()) {
    try {
      await file.delete();
    } catch (e) {
      throw Exception("Error deleting file ${file.path}: $e");
    }
  } else {
    throw Exception("File does not exist: ${file.path}");
  }
}