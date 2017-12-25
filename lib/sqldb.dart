import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

final String tableUser = "user";
final String userId = "iduser";
final String userLogin = "login";
final String userPassword = "password";

final String tableStatistics = "statistics";
final String statisticsId = "idstatistics";
final String dateTime = "datetime";
final String idUser = "user_id";

final String tableCalories = "calories";
final String caloriesId = "idcalories";
final String caloriesCount = "caloriescount";
final String idStatistics = "statistics_id";

final String tableExercise = "exercise";
final String exerciseId = "idexercise";
final String exerciseName = "exercisename";
final String exerciseMinutes = "exerciseminutes";
final String exerciseCalories = "exercisecalories";

final String tableCustomExercise = "customexercise";
final String customExerciseId = "customidexercise";
final String customExerciseName = "customexercisename";
final String customExerciseMinutes = "customexerciseminutes";
final String customExerciseCalories = "customexercisecalories";
final String customIdUser = "iduser";

class User {
  User({this.login, this.password, this.caloriesnorm, this.resetcalories, this.idtypeexercise});
  int iduser;
  String login;
  String password;
  int caloriesnorm;
  int resetcalories;
  int idtypeexercise;

  Map toMap() {
    Map map = {
      userLogin: login, 
      userPassword: password
    };
    if (iduser != null) {
      map[userId] = iduser;
    }
    return map;
  }

  User.fromMap(Map map) {
    iduser = map[userId];
    login = map[userLogin];
    password = map[userPassword];
  }
}

class Statistics {
  Statistics({this.datetime, this.iduser});  
  int idstatistics;
  String datetime;
  int iduser;

  Map toMap() {
    Map map = {
      dateTime: datetime, 
      idUser: iduser
    };
    if (idstatistics != null) {
      map[statisticsId] = idstatistics;
    }
    return map;
  }

  Statistics.fromMap(Map map) {
    idstatistics = map[statisticsId];
    datetime = map[dateTime];
    iduser = map[idUser];
  }
}

class Calories {
  Calories({this.caloriescount, this.idstatistics});
  int idcalories;
  int caloriescount;
  int idstatistics;

  Map toMap() {
    Map map = {
      caloriesCount: caloriescount, 
      idStatistics: idstatistics
    };
    if (idcalories != null) {
      map[caloriesId] = idcalories;
    }
    return map;
  }

  Calories.fromMap(Map map) {
    idcalories = map[caloriesId];
    caloriescount = map[caloriesCount];
    idstatistics = map[idStatistics];
  }
}

class Exercise {
  Exercise({this.exercisename, this.exerciseminutes, this.exercisecalories});
  int idexercise;
  String exercisename;
  int exerciseminutes;
  int exercisecalories;

  Map toMap() {
    Map map = {
      exerciseName: exercisename, 
      exerciseMinutes: exerciseminutes,
      exerciseCalories: exercisecalories
    };
    if (idexercise != null) {
      map[exerciseId] = idexercise;
    }
    return map;
  }

  Exercise.fromMap(Map map) {
    idexercise = map[exerciseId];
    exercisename = map[exerciseName];
    exerciseminutes = map[exerciseMinutes];
    exercisecalories = map[exerciseCalories];
  }
}

class CustomExercise {
  CustomExercise({
    this.customexercisename,
    this.customexerciseminutes,
    this.customexercisecalories,
    this.customiduser,
  });
  int customidexercise;
  String customexercisename;
  int customexerciseminutes;
  int customexercisecalories;
  int customiduser;

  Map toMap() {
    Map map = {
      customExerciseName: customexercisename, 
      customExerciseMinutes: customexerciseminutes,
      customExerciseCalories: customexercisecalories,
      customIdUser: customiduser
    };
    if (customidexercise != null) {
      map[customExerciseId] = customidexercise;
    }
    return map;
  }

  CustomExercise.fromMap(Map map) {
    customidexercise = map[customExerciseId];
    customexercisename = map[customExerciseName];
    customexerciseminutes = map[customExerciseMinutes];
    customexercisecalories = map[customExerciseCalories];
    customiduser = map[customIdUser];
  }
}

List<Exercise> listExercise = <Exercise>[
  new Exercise(exercisename: 'Running (1 kilometers)', exerciseminutes: 10, exercisecalories: 500,),
  new Exercise(exercisename: 'Running (3 kilometers)', exerciseminutes: 30, exercisecalories: 700,),
  new Exercise(exercisename: 'Running (5 kilometers)', exerciseminutes: 60, exercisecalories: 900,),
  new Exercise(exercisename: 'Running (10 kilometers)', exerciseminutes: 90, exercisecalories: 1200,),
  new Exercise(exercisename: 'Basketball', exerciseminutes: 60, exercisecalories: 1555,),
  new Exercise(exercisename: 'Football', exerciseminutes: 45, exercisecalories: 856,),
  new Exercise(exercisename: 'Volleyball', exerciseminutes: 60, exercisecalories: 900,),
  new Exercise(exercisename: 'Push-up', exerciseminutes: 30, exercisecalories: 465,),
  new Exercise(exercisename: 'Pulling', exerciseminutes: 60, exercisecalories: 764,),
  new Exercise(exercisename: 'Squatting', exerciseminutes: 60, exercisecalories: 406,),
  new Exercise(exercisename: 'The bench press', exerciseminutes: 30, exercisecalories: 356,),
  new Exercise(exercisename: 'Press', exerciseminutes: 30, exercisecalories: 489,),
  new Exercise(exercisename: 'Swimming', exerciseminutes: 120, exercisecalories: 764,),
  new Exercise(exercisename: 'Boxing', exerciseminutes: 60, exercisecalories: 1640,),
  new Exercise(exercisename: 'Fast walking', exerciseminutes: 40, exercisecalories: 670,),
  new Exercise(exercisename: 'Walking on the stairs', exerciseminutes: 35, exercisecalories: 429,),
  new Exercise(exercisename: 'Aerobika', exerciseminutes: 60, exercisecalories: 1105,),
  new Exercise(exercisename: 'Jump Rope', exerciseminutes: 30, exercisecalories: 670,),
  new Exercise(exercisename: 'A bike', exerciseminutes: 80, exercisecalories: 1800,),
  new Exercise(exercisename: 'Skiing', exerciseminutes: 90, exercisecalories: 1479,),
  new Exercise(exercisename: 'Hoop', exerciseminutes: 60, exercisecalories: 300,),
  new Exercise(exercisename: 'Gymnastics', exerciseminutes: 70, exercisecalories: 1370,),
];

List<Statistics> listDate = <Statistics>[
  new Statistics(datetime: '2017-12-29', iduser: 1),    
  new Statistics(datetime: '2017-11-30', iduser: 1),
  new Statistics(datetime: '2017-12-01', iduser: 1),
  new Statistics(datetime: '2017-12-02', iduser: 1),
  new Statistics(datetime: '2017-12-03', iduser: 1),
  new Statistics(datetime: '2017-12-04', iduser: 1),
  new Statistics(datetime: '2017-12-05', iduser: 1),
  new Statistics(datetime: '2017-12-06', iduser: 1),
  new Statistics(datetime: '2017-12-07', iduser: 1),
  new Statistics(datetime: '2017-12-08', iduser: 1),
]; 

List<int> listCalor = <int>[
  100,
  200,
  300,
  400,
  500,
  600,
  550,
  450,
  350,
  250,
];

class DBProvider {
  Database db;

  Future create() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    String dbPath = join(path, "database8.db");
    await open(dbPath).then((val) {
      getAllUser().then((onValue) {
        if (onValue == null) {
          addAll();
        }
      });
    });
  }

  addAll() async {
    int id = await db.rawInsert('insert into user(login, password) values ("Vlad", "vlad")');
    print(id);
    for (int i = 0; i < listExercise.length; i++) {
      await insertExercise(listExercise[i]);
    }
    await deleteAllCalories().then((onValue) {
      deleteAllStatistics().then((onValue) {
        for (int i = 0; i< listDate.length; i++) {
          insertStatistics(listDate[i]).then((value) {
            print(value.datetime);
            Calories calories = new Calories(
              caloriescount: listCalor[i],
              idstatistics: value.idstatistics
            );
            insertCalories(calories).then((val) {
              print(val.idcalories);
            });
          });
        }
      });
    });
  }

  Future open(String path) async {
    db = await openDatabase(path, version: 1, onCreate: (Database db, int newVersion) async {
      await db.execute('''
        create table $tableUser ( 
          $userId integer primary key autoincrement, 
          $userLogin text not null,
          $userPassword text not null
        );
      ''');
      await db.execute('''
        create table $tableStatistics (
          $statisticsId integer primary key autoincrement,
          $dateTime text not null,
          $idUser integer not null,
          FOREIGN KEY ($idUser) REFERENCES $tableUser($userId)
        );
      ''');
      await db.execute('''
        create table $tableCalories (
          $caloriesId integer primary key autoincrement,
          $caloriesCount integer not null,
          $idStatistics integer not null,
          FOREIGN KEY ($idStatistics) REFERENCES $tableStatistics($statisticsId)
        );
      ''');
      await db.execute('''
        create table $tableExercise (
          $exerciseId integer primary key autoincrement,
          $exerciseName text not null,
          $exerciseMinutes integer not null,
          $exerciseCalories integer not null
        );
      ''');
      await db.execute('''
        create table $tableCustomExercise (
          $customExerciseId integer primary key autoincrement,
          $customExerciseName text not null,
          $customExerciseMinutes integer not null,
          $customExerciseCalories integer not null,
          $customIdUser integer not null,
          FOREIGN KEY ($customIdUser) REFERENCES $tableUser($userId)
        );
      ''');
    });
  }

  Future<User> insertUser(User user) async {
    user.iduser = await db.insert(tableUser, user.toMap());
    return user;
  }

  Future<Statistics> insertStatistics(Statistics statistics) async {
    statistics.idstatistics = await db.insert(tableStatistics, statistics.toMap());
    return statistics;
  }

  Future<Calories> insertCalories(Calories calories) async {
    calories.idcalories = await db.insert(tableCalories, calories.toMap());
    return calories;
  }

  Future<Exercise> insertExercise(Exercise exercise) async {
    exercise.idexercise = await db.insert(tableExercise, exercise.toMap());
    print(exercise.idexercise);
    return exercise;
  }

  Future<CustomExercise> insertCustomExercise(CustomExercise customexercise) async {
    customexercise.customidexercise = await db.insert(tableCustomExercise, customexercise.toMap());
    return customexercise;
  }

  Future<User> getUser(int iduser) async {
    List<Map> maps = await db.query(tableUser,
        columns: [userId, userPassword, userLogin],
        where: "$userId = ?",
        whereArgs: [iduser]);
    if (maps.length > 0) {
      return new User.fromMap(maps.first);
    }
    return null;
  }

  Future<User> getUserByLogin(String login) async {
    List<Map> maps = await db.rawQuery("select * from $tableUser where $userLogin like '$login'");
    if (maps.length > 0) {
      return new User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Map>> getStatisticsByDate(String datetime) async {
    List<Map> maps = await db.rawQuery("select * from $tableStatistics where $dateTime like '$datetime'");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<List<Map>> getStatisticsByCustomDate(String dateFrom, String dateTo) async {
    List<Map> maps = await db.rawQuery("select * from $tableStatistics where $dateTime between '$dateFrom' and '$dateTo'");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<List<Map>> getExerciseByName(String name) async {
    List<Map> maps = await db.rawQuery("select * from $tableExercise where $exerciseName like '%$name%'");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<List<Map>> getCustomExerciseByName(String name) async {
    List<Map> maps = await db.rawQuery("select * from $tableCustomExercise where $customExerciseName like '%$name%'");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<List<Map>> getCaloriesByIdStatistics(int idstat) async {
    List<Map> maps = await db.rawQuery("select * from $tableCalories where $idStatistics=$idstat");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<User> getAllUser() async {
    List<Map> maps = await db.rawQuery("select * from $tableUser");
    if (maps.length > 0) {
      return new User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Map>> getAllStatistics() async {
    List<Map> maps = await db.rawQuery("select * from $tableStatistics");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<List<Map>> getAllCalories() async {
    List<Map> maps = await db.rawQuery("select * from $tableCalories");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<List<Map>> getAllExercise() async {
    List<Map> maps = await db.rawQuery("select * from $tableExercise");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<List<Map>> getAllCustomExercise(int iduser) async {
    List<Map> maps = await db.rawQuery("select * from $tableCustomExercise where $customIdUser = $iduser");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<int> deleteUser(int iduser) async {
    return await db.delete(tableUser, where: "$userId = ?", whereArgs: [iduser]);
  }

  Future<int> deleteAllUser() async {
    return await db.rawDelete("delete from $tableUser");
  }

  Future<int> deleteAllStatistics() async {
    return await db.rawDelete("delete from $tableStatistics");
  }

  Future<int> deleteAllCalories() async {
    return await db.rawDelete("delete from $tableCalories");
  }

  Future<int> updateUser(User user) async {
    return await db.update(tableUser, user.toMap(),
        where: "$userId = ?", whereArgs: [user.iduser]);
  }

  Future close() async => db.close();
}