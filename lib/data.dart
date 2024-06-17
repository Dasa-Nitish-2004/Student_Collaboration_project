import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/request_bluePrint.dart';

Future<List> get getskills async {
  Db db = await MongoDb().getConnection();
  List skill = [];
  var skills = await db.collection('availskill');
  var k = await skills.find(where.sortBy('skill').fields(['skills'])).toList();
  k.forEach((element) {
    skill = element['skills'];
  });
  // print(skill);
  db.close();
  return skill;
}

Future<Map> getUserData(String email) async {
  var db = await MongoDb().getConnection();
  var info = await db.collection('user_info');
  var k = await info.find(where.eq("id", email)).toList();
  db.close();
  return k[0];
}

List<Request> req = [];
void addRequest(Request k) {
  req.add(k);
}
