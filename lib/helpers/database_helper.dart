import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('service_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabel Users
    await db.execute('''
    CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'admin'
    )
    ''');

    // Tabel Settings
    await db.execute('''
    CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_name TEXT,
        note_header TEXT,
        note_footer TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
    ''');

    // Tabel Customers
    await db.execute('''
    CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT
    )
    ''');

    // Tabel Deposited Items
    await db.execute('''
    CREATE TABLE deposited_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        brand TEXT,
        model TEXT,
        serial_number TEXT,
        received_date TEXT NOT NULL,
        complaint TEXT,
        status TEXT DEFAULT 'waiting',
        estimated_cost REAL,
        final_cost REAL,
        pickup_date TEXT,
        technician TEXT,
        notes TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers(id)
    )
    ''');

    // Tabel Service Logs
    await db.execute('''
    CREATE TABLE service_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deposited_item_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        action TEXT NOT NULL,
        component_used TEXT,
        component_cost REAL,
        technician TEXT,
        notes TEXT,
        FOREIGN KEY (deposited_item_id) REFERENCES deposited_items(id)
    )
    ''');

    // Tabel Transactions
    await db.execute('''
    CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deposited_item_id INTEGER,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT,
        description TEXT,
        transaction_date TEXT NOT NULL,
        FOREIGN KEY (deposited_item_id) REFERENCES deposited_items(id)
    )
    ''');

    // Tabel Savings
    await db.execute('''
    CREATE TABLE savings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        date TEXT NOT NULL
    )
    ''');

    // Tabel Purchases
    await db.execute('''
    CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        category TEXT,
        quantity REAL,
        unit_price REAL,
        total_price REAL,
        purchase_date TEXT NOT NULL,
        notes TEXT
    )
    ''');

    // Tambahkan user admin default
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin'
    });

    // Tambahkan pengaturan default
    await db.insert('settings', {
      'business_name': 'Toko Servis',
      'note_header': 'Terima kasih telah mempercayakan servis kepada kami',
      'note_footer': 'Garansi servis berlaku 7 hari',
      'updated_at': DateTime.now().toIso8601String()
    });
  }

  // Metode umum untuk CRUD

  // Create
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(table, data);
  }

  // Read
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    final db = await instance.database;
    final maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Update
  Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // Delete
  Future<int> delete(String table, int id) async {
    final db = await instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Metode khusus untuk query kompleks
  Future<List<Map<String, dynamic>>> getDepositedItemsWithCustomer() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT di.*, c.name as customer_name
      FROM deposited_items di
      JOIN customers c ON di.customer_id = c.id
    ''');
  }

  Future<List<Map<String, dynamic>>> getServiceLogsByItemId(int itemId) async {
    final db = await instance.database;
    return await db.query(
      'service_logs',
      where: 'deposited_item_id = ?',
      whereArgs: [itemId],
    );
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getWaitingDepositedItems() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT di.*, c.name as customer_name
      FROM deposited_items di
      JOIN customers c ON di.customer_id = c.id
      WHERE di.status = 'waiting'
      ORDER BY di.received_date DESC
      LIMIT 5
    ''');
  }

  Future<bool> isUsernameAvailable(String username, {int? excludeUserId}) async {
    final db = await instance.database;
    final query = excludeUserId != null
        ? 'SELECT COUNT(*) as count FROM users WHERE username = ? AND id != ?'
        : 'SELECT COUNT(*) as count FROM users WHERE username = ?';
    final args = excludeUserId != null ? [username, excludeUserId] : [username];
    
    final result = await db.rawQuery(query, args);
    final count = Sqflite.firstIntValue(result);
    return count == 0;
  }

  Future<bool> updateUsername(int userId, String newUsername) async {
    final db = await instance.database;
    
    // Cek apakah username tersedia
    final isAvailable = await isUsernameAvailable(newUsername, excludeUserId: userId);
    if (!isAvailable) {
      return false;
    }

    // Update username
    await db.update(
      'users',
      {'username': newUsername},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return true;
  }

  Future<bool> verifyPassword(int userId, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, password],
    );
    return result.isNotEmpty;
  }

  Future<bool> updatePassword(int userId, String currentPassword, String newPassword) async {
    // Verifikasi password lama
    final isValid = await verifyPassword(userId, currentPassword);
    if (!isValid) {
      return false;
    }

    final db = await instance.database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return true;
  }

  Future<bool> deleteAccount(int userId, String password) async {
    // Verifikasi password
    final isValid = await verifyPassword(userId, password);
    if (!isValid) {
      return false;
    }

    final db = await instance.database;
    await db.transaction((txn) async {
      // Hapus semua data terkait user
      await txn.delete('transactions', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('service_logs', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('purchases', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('deposited_items', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('savings', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('customers', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('settings', where: 'user_id = ?', whereArgs: [userId]);
      // Hapus user
      await txn.delete('users', where: 'id = ?', whereArgs: [userId]);
    });
    return true;
  }
}
