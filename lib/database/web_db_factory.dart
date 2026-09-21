import 'db_factory_stub.dart'
    if (dart.library.html) 'db_factory_web.dart' as db_factory;

/// Inisialisasi factory SQLite khusus web (IndexedDB) bila dijalankan
/// di browser. Pada platform io tidak melakukan apa-apa.
Future<void> initDatabaseFactory() => db_factory.initDatabaseFactory();

/// Nama/path database. Di web database disimpan di IndexedDB sehingga
/// hanya berupa nama tetap; di platform lain path diabaikan (tidak
/// dipanggil).
String webDbPath(String name) => db_factory.dbPath(name);