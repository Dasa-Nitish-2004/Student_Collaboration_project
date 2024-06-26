import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:scolab/request_bluePrint.dart';
import 'package:scolab/data.dart' as data;
import 'package:scolab/DatabaseService/HiveService.dart';

class MongoDb {
  Future<Db> getConnection() async {
    String pass = "dasa6302081627";
    var db = await Db.create(
        "mongodb+srv://dasanitish2004:$pass@userdata.marephd.mongodb.net/sample_mflix?retryWrites=true&w=majority&appName=UserData");
    await db.open();
    return db;
  }

  static Future<void> sendConnectRequest(
      {required String mssg,
      required Map reciver,
      required String project,
      required String sender}) async {
    if (!await MongoDb.checkRequestMessg(
        mssg: mssg, project: project, reciver: reciver, sender: sender)) {
      Db db = await MongoDb().getConnection();
      db.collection("requestMessage").insert({
        "sender": sender,
        "reciver": reciver['id'],
        "project": project,
        "date": DateTime.now(),
        "message": mssg
      });
      HiveService.addRequestedRequest({
        "sender": sender,
        "reciver": reciver['id'],
        "project": project,
        "date": DateTime.now(),
        "message": mssg
      });
      db.close();
    }
  }

  static Future<List<Map<dynamic, dynamic>>> updateLocalRequested() async {
    print("database called");
    var db = await MongoDb().getConnection();
    var requestedData = await db
        .collection("requestMessage")
        .find(where.eq("sender", data.hostemail))
        .toList();
    print(requestedData);
    db.close();
    return requestedData;
  }

  static Future<List<Map<dynamic, dynamic>>> updateLocalRecevied() async {
    String mail = 'dasanitish2004@gmail.com';
    print("database called");
    var db = await MongoDb().getConnection();
    var requestedData = await db
        .collection("requestMessage")
        .find(where.eq("reciver", mail))
        .toList();
    print(requestedData);
    db.close();
    return requestedData;
  }

  static Future<bool> checkRequestMessg(
      {required String mssg,
      required String project,
      required Map reciver,
      required String sender}) async {
    Db db = await MongoDb().getConnection();
    var result = await db
        .collection("requestMessage")
        .find(where
            .eq("sender", sender)
            .eq("reciver", reciver["id"])
            .eq("project", project))
        .toList();
    db.close();
    if (result.isEmpty) {
      return false;
    }
    return true;
    //true if exists else false
  }

  static Future<void> deleteRequest(Map request) async {
    var db = await MongoDb().getConnection();
    try {
      db.collection("requestMessage").deleteMany({
        "sender": request["sender"],
        "project": request["project"],
        "reciver": request["reciver"]
      });
    } catch (e) {
      print("unable to delete");
    }
    db.close();
  }

  Future<void> modifyUser(Db db, String email,
      {String? user_desc,
      String? github,
      String? linkedin,
      List? skills,
      List? projects}) async {
    var modifier = modify;

    if (user_desc != null) {
      modifier = modifier.set('user_description', user_desc);
    }
    if (github != null) {
      modifier = modifier.set('github', github);
    }
    if (linkedin != null) {
      modifier = modifier.set('linkedin', linkedin);
    }
    if (skills != null && skills.isNotEmpty) {
      modifier = modifier.set('skill', skills);
    }
    if (projects != null && projects.isNotEmpty) {
      modifier = modifier.set('projects', projects);
    }

    // Perform the update
    if (modifier.map.isNotEmpty) {
      await db.collection("user_info").updateOne(
            where.eq('id', email),
            modifier,
          );
    }
  }

  Future<void> updateSkill(Db db, List<String> skillSuggestions) async {
    var skill = skillSuggestions.toSet();
    skillSuggestions = skill.toList();
    var collection = db.collection('availskill');
    await collection.updateOne(
      where.eq('type', 'skill'),
      modify.set('skills', skillSuggestions),
      upsert: true, // This will insert the skill if it doesn't exist
    );
  }

  Future<List> getIds(Db db) async {
    List obj;
    List data = [];
    var movies = await db.collection("user_info");
    obj = (await movies.find(where.sortBy('id').fields(['id'])).toList());
    obj.forEach(
      (ele) {
        data.add(ele['id']);
      },
    );
    return data;
  }

  void addUser(Db db, String mail) async {
    var user = await db.collection("user_info");
    if (await checkUserExists(db, mail)) {
      await user.insert({
        "id": mail,
        "type": "user",
        "skill": [],
        'projects': [],
        'github': "",
        'linkedin': '',
        'likes': 0,
        'user_description': '',
      });

      await db.collection("favorites").insert({"id": mail, "favorites": []});
    }
  }

  Future<List<Map<String, dynamic>>> fetchRequestsBySkillSortedByLikes(
      Db db, String skill) async {
    var requestsCollection = db.collection('requests');

    var pipeline = [
      {
        '\$lookup': {
          'from': 'user_info',
          'localField': 'Hostname',
          'foreignField': 'id',
          'as': 'user_info',
        }
      },
      {
        '\$unwind': '\$user_info',
      },
      {
        '\$match': {
          'skills.skill': skill,
          'Hostname': {'\$ne': data.hostemail},
        }
      },
      {
        '\$sort': {
          'user_info.likes': -1,
        }
      },
      {
        '\$project': {
          '_id': 1,
          'projectTitle': 1,
          'projectDesc': 1,
          'Hostname': 1,
          'Participants': 1,
          'date': 1,
          'skills': 1,
          'user_likes': '\$user_info.likes',
        }
      }
    ];

    var result = await requestsCollection.aggregateToStream(pipeline).toList();
    await db.close();
    return result;
  }

  static void updateFav(List<String> fav) async {
    var db = await MongoDb().getConnection();
    await db.collection("favorites").updateOne(
        where.eq("id", data.hostemail), modify.set("favorites", fav));
    db.close();
  }

  Future<void> incrementLikes(Db db, String userId) async {
    await db.collection("user_info").updateOne(
          where.eq('id', userId),
          modify.inc('likes', 1),
        );
  }

  Future<void> decrementLikes(Db db, String userId) async {
    await db.collection("user_info").updateOne(
          where.eq('id', userId),
          modify.inc('likes', -1),
        );
  }

  Future<void> addRequest(
      Db db, Request request, Request prev, bool status) async {
    var collection = db.collection('requests');

    if (status) {
      var modifier = modify;

      modifier = modifier.set('projectTitle', request.projectTitle);
      modifier = modifier.set('projectDesc', request.projectDesc);
      modifier = modifier.set('date', request.date);
      modifier = modifier.set('skills', request.skills);
      // Perform the update
      if (modifier.map.isNotEmpty) {
        await collection.updateOne(
          where
              .eq('Hostname', request.Hostname)
              .eq('projectTitle', prev.projectTitle),
          modifier,
        );
      }
    } else {
      await collection.insert(request.toMap());
    }
  }

  Future checkUserExists(Db db, String email) async {
    List obj;
    var movies = await db.collection("user_info");
    obj = (await movies.find(where.eq('id', email)).toList());
    if (obj.isEmpty) {
      return true;
    }
    return false;
  }
}
