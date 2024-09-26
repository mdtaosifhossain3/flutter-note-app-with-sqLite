import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  //Singleton
  // data base bar bar instance kora thik na. cuz ete duplication hote pare. tai instance kei private kore nesi. jate kew instance na korte pare kew.
  DbHelper._();

  static final DbHelper getInstance = DbHelper._();

  Database? myDB;

  //Table note
  final String TABLE_NOTE = 'note';
  final String COLUMN_NOTE_SNO = 's_no';
  final String COLUMN_NOTE_TITLE = 'title';
  final String COLUMN_NOTE_DESC = 'desc';

  ///db open(path -> if exsist then open else create db)

  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;

    //Alternative
    // if (myDB != null) {
    //   return myDB!;
    // } else {
    //   myDB = await openDB();
    //   return myDB!;
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbpath = join(appDir.path, 'note.db');

    return await openDatabase(dbpath, onCreate: (db, version) {
      //create all your tables here
      //autoincrement - primary key to ami dei ni. jehetu autoincrement bolsi tai eta auto generate hoye jabe

      //basically ekhane data requried na. not null bosale data gulo requried hoye jabe.
      db.execute(
          "create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement,$COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)");
    }, version: 1);
  }

  ///all queries
  ///insertion
  Future<bool> addNote({required String nTitle, required String nDesc}) async {
    var db = await getDB();
    //Single Rows - Map
    // Multiple Rows - List

    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: nTitle,
      COLUMN_NOTE_DESC: nDesc,
    });

    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();

    //Data asbe tobe rows akare. orhtat row onu jai ekta ekta list.
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);

    return mData;
  }

  Future<bool> updateNote(
      {required int s_no, required String title, required String desc}) async {
    var db = await getDB();

    int rowEffected = await db.update(
        TABLE_NOTE, {COLUMN_NOTE_TITLE: title, COLUMN_NOTE_DESC: desc},
        where: "$COLUMN_NOTE_SNO = $s_no");

    return rowEffected > 0;
  }

  //Delete Note
  Future<bool> deleteNote({required String sNo}) async {
    print(sNo);
    var db = await getDB();

    int rowEffected =
        await db.delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = $sNo");
    print(rowEffected);
    return rowEffected > 0;
  }

  //Delete Note
  // Future<bool> deleteNote({required int sNo}) async {
  //   var db = await getDB();

  //   int rowEffected = await db
  //       .delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ?", whereArgs: ["$sNo"]);

  //   return rowEffected > 0;
  // }
}
