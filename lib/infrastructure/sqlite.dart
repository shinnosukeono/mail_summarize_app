import 'package:format/format.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mail_app/repository/mail_summarize.dart';

const databaseName = 'database.db';

const createDataBaseCommand = 'CREATE TABLE schedules(id TEXT, schedule TEXT)';

const queryIdCommand = 'SELECT * FROM schedules WHERE id IN ({0})';

Future<bool> checkDatabaseExists(String email) async {
  final emailHead = email.substring(0, email.length - 10);
  return databaseExists(
      '{0}/{1}_{2}'.format(await getDatabasesPath(), emailHead, databaseName));
}

Future<Database> connectToDataBase(String email) async {
  final emailHead = email.substring(0, email.length - 10);
  return openDatabase(
      '{0}/{1}_{2}'.format(await getDatabasesPath(), emailHead, databaseName));
}

Future<Database> createDataBase(String email) async {
  final emailHead = email.substring(0, email.length - 10);
  return openDatabase(
      '{0}/{1}_{2}'.format(await getDatabasesPath(), emailHead, databaseName),
      onCreate: (db, version) {
    return db.execute(
      createDataBaseCommand,
    );
  }, version: 1);
}

Future<List<ListSchedules>> getAllData(Database dataBase) async {
  final List<Map<String, dynamic>> maps = await dataBase.query('schedules');
  return maps.map((e) {
    return ListSchedules(id: e['id'], schedule: e['schedule']);
  }).toList();
}

Future<List<ListSchedules>> getDataFromIDList(
    Database database, List<String> idList) async {
  final String keysString = idList.map((key) => "'$key'").join(', ');
  final String query = queryIdCommand.format(keysString);
  final List<Map<String, dynamic>> maps = await database.rawQuery(query);
  return maps.map((e) {
    return ListSchedules(id: e['id'], schedule: e['schedule']);
  }).toList();
}

Future<void> insertData(Database database, List<ListSchedules> schedule) async {
  for (final ListSchedules e in schedule) {
    await database.insert(
      'schedules',
      {'id': e.id, 'schedule': e.schedule},
      conflictAlgorithm: ConflictAlgorithm.replace, //has no effect
    );
  }
}
