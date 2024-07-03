import 'dart:async';

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
// List<Map<String, dynamic>> skills = [];
// List<Map<String, dynamic>> projects = [];
List<dynamic> skills = [];
List<dynamic> projects = [];

Future<List> get getskills async {
  List skill = [];
  try {
    var db = await MongoDb().getConnection();
    var skillsCollection = db.collection('availskill');
    var k = await skillsCollection
        .find(where.sortBy('skill').fields(['skills']))
        .toList();
    for (var element in k) {
      skill = element['skills'];
    }
    await db.close();
  } catch (e) {
    print("Error fetching skills: $e");
  }
  return skill;
}

Future<Map> getUserData(String email) async {
  Map userData = {};
  try {
    var db = await MongoDb().getConnection();
    var info = db.collection('user_info');
    var k = await info.find(where.eq("id", email)).toList();
    if (k.isNotEmpty) {
      userData = k[0];
    }
    await db.close();
  } catch (e) {
    print("Error fetching user data: $e");
  }
  return userData;
}

Future<Map> getRequest(String email, String title) async {
  Map requestData = {};
  try {
    var db = await MongoDb().getConnection();
    var info = db.collection('requests');
    var k = await info
        .find(where.eq("Hostname", email).eq("projectTitle", title))
        .toList();
    if (k.isNotEmpty) {
      requestData = k[0];
    }
    await db.close();
  } catch (e) {
    print("Error fetching request data: $e");
  }
  return requestData;
}

Future<void> addResponse() async {
  try {
    var prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    if (email == null || req.isNotEmpty) {
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
        print("Error parsing request: $e");
      }
    }

    await db.close();
  } catch (e) {
    print("Error adding response: $e");
  }
}

Future<void> deleteResponse(Request k) async {
  try {
    var prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    if (email == null) {
      return;
    }

    var db = await MongoDb().getConnection();
    var info = db.collection('requests');
    await info.deleteMany({"Hostname": email, "projectTitle": k.projectTitle});
    await db.close();
  } catch (e) {
    print("Error deleting response: $e");
  }
}

void addRequest(Request k) {
  req.add(k);
}

Future<void> getSkill() async {
  if (dataSkills.isEmpty) {
    try {
      var db = await MongoDb().getConnection();
      var skillsCollection = db.collection('availskill');
      var k = (await skillsCollection
          .find(where.sortBy('skill').fields(['skills']))
          .toList())[0];
      for (var element in k["skills"]) {
        dataSkills.add(element);
      }
      // dataSkills = k["skills"];
      print(dataSkills);
      print(dataSkills);
      await db.close();
    } catch (e) {
      print("Error fetching skills: $e");
    }
  }
}
