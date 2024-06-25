import 'dart:async';
import 'dart:ffi';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/request_bluePrint.dart';
import 'package:shared_preferences/shared_preferences.dart';

String hostemail = "";
List<String> dataSkills = [];
List<Request> req = [];

String user_desc = "";
String github = "";
String linkedIn = "";
List<Map<String, dynamic>> skills = [];
List<Map<String, dynamic>> projects = [];

Future<List> get getskills async {
  Db db = await MongoDb().getConnection();
  List skill = [];
  var skills = await db.collection('availskill');
  var k = await skills.find(where.sortBy('skill').fields(['skills'])).toList();
  k.forEach((element) {
    skill = element['skills'];
  });
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

Future<Map> getRequest(String email, String title) async {
  var db = await MongoDb().getConnection();
  var info = await db.collection('requests');
  var k = await info
      .find(where.eq("Hostname", email).eq("projectTitle", title))
      .toList();
  db.close();
  return k[0] ?? {};
}

Future<void> addResponse() async {
  var prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString("email");
  if (email == null || req.length > 0) {
    return;
  }

  var db = await MongoDb().getConnection();
  var info = db.collection('requests');
  var k = await info.find(where.eq("Hostname", email)).toList();

  for (var element in k) {
    try {
      req.add(Request(
        projectTitle: element['projectTitle'],
        projectDesc: element['projectDesc'],
        Hostname: element['Hostname'],
        Participants: element['Participants'],
        date: element['date'],
        skills: element['skills'],
      ));
    } catch (e) {
      // print("this is the error ${e}");
    }
  }
  // print("request in data file ______ ${req.length}");

  await db.close();
}

Future<void> deleteResponse(Request k) async {
  var prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString("email");
  if (email == null) {
    return;
  }

  var db = await MongoDb().getConnection();
  var info = db.collection('requests');
  await info.deleteMany({"Hostname": email, "projectTitle": k.projectTitle});
  await db.close();
}

void addRequest(Request k) {
  req.add(k);
}

Future<void> getSkill() async {
  if (dataSkills.length == 0) {
    Db db = await MongoDb().getConnection();
    List skill = [];
    var skills = await db.collection('availskill');
    var k =
        await skills.find(where.sortBy('skill').fields(['skills'])).toList();
    k.forEach((element) {
      skill = element['skills'];
    });
    skill.forEach((element) {
      dataSkills.add(element);
    });
    db.close();
  }
}
