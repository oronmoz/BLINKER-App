import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


/// Creates and manages the local SQLite database.
///
/// This class is responsible for initializing the database and defining the schema for the required tables.
class LocalDatabaseFactory {

  /// Creates a new SQLite database instance.
  ///
  /// Returns the created [Database] instance.
  Future<Database> createDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'blinker.db');

    var database = await openDatabase(dbPath, version: 8, onCreate: populateDb);
    return database;
  }

  /// Populates the database with the required tables.
  ///
  /// [db] - The [Database] instance.
  /// [version] - The database version.
  void populateDb(Database db, int version) async {
    await _createChatTable(db);
    await _createMessagesTable(db);
  }

  /// Creates the 'chats' table in the database.
  ///
  /// [db] - The [Database] instance.
  _createChatTable(Database db) async {
    await db
        .execute(
          """CREATE TABLE chats(
            id TEXT PRIMARY KEY,
            name TEXT,
            type TEXT,
            members TEXT,
            mostRecent TEXT,
            unread TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
            )""",
        )
        .then((_) => print('creating table chats...'))
        .catchError((e) => print('error creating chats table: $e'));
  }

  /// Creates the 'messages' table in the database.
  ///
  /// [db] - The [Database] instance.
  _createMessagesTable(Database db) async {
    await db
        .execute("""
          CREATE TABLE messages(
            chat_id TEXT NOT NULL,
            id TEXT PRIMARY KEY,
            sender TEXT NOT NULL,
            receiver TEXT NOT NULL,
            contents TEXT NOT NULL,
            receipt TEXT NOT NULL,
            received_at TIMESTAMP NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
            )
      """)
        .then((_) => print('creating table messages'))
        .catchError((e) => print('error creating messages table: $e'));
  }
}
