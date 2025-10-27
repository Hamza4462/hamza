import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class FileManager {
  static Future<String?> pickFile() async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (res == null) return null;
    return res.files.single.path;
  }

  static Future<String?> pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res == null) return null;
    return res.files.single.path;
  }

  static Future<List<String>> pickFiles() async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (res == null) return [];
    return res.files.map((f) => f.path!).toList();
  }

  // Copy file into app documents directory and return new path
  static Future<String?> copyToAppDir(String srcPath) async {
    try {
      final src = File(srcPath);
      if (!await src.exists()) return null;
      final docs = await getApplicationDocumentsDirectory();
      final filename = p.basename(srcPath);
      final dest = File(p.join(docs.path, filename));
      await src.copy(dest.path);
      return dest.path;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> saveStringToFile(String filename, String content) async {
    final docs = await getApplicationDocumentsDirectory();
    final file = File(p.join(docs.path, filename));
    await file.writeAsString(content);
    return file.path;
  }

  static Future<String?> saveCopyToTemp(String srcPath) async {
    try {
      final src = File(srcPath);
      if (!await src.exists()) return null;
      final tmp = Directory.systemTemp;
      final filename = p.basename(srcPath);
      final dest = File(p.join(tmp.path, filename));
      await src.copy(dest.path);
      return dest.path;
    } catch (_) {
      return null;
    }
  }

}
