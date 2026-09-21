import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Di web, database disimpan di IndexedDB lewat sqlite3.wasm yang
/// dibundel di folder `web/` (lihat `dart run sqflite_common_ffi_web:setup`).
Future<void> initDatabaseFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
}

/// Path web hanya berupa nama file; lokasi fisik dikelola sqflite di IndexedDB.
String dbPath(String name) => name;