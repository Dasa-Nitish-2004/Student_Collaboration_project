import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:scolab/request_bluePrint.dart';
import 'package:scolab/data.dart' as data;
import 'package:scolab/DatabaseService/HiveService.dart';

class MongoDb {
  // Establishes a connection to the MongoDB database.
  Future<Db> getConnection() async {
    const String pass = "dasa6302081627";
    final db = await Db.create(
        "mongodb+srv://dasanitish2004:$pass@userdata.marephd.mongodb.net/sample_mflix?retryWrites=true&w=majority&appName=UserData");
    await db.open();
    return db;
  }

  // Sends a connection request to a receiver if the message doesn't already exist.
  static Future<void> sendConnectRequest({
    required String mssg,
    required Map reciver,
    required String project,
    required String sender,
  }) async {
    if (!await MongoDb.checkRequestMessg(
      mssg: mssg,
      project: project,
      reciver: reciver,
      sender: sender,
    )) {
      final db = await MongoDb().getConnection();
      await db.collection("requestMessage").insert({
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
      await db.close();
    }
  }

  static Future<void> addParticipant(Map notif) async {
    var db = await MongoDb().getConnection();
    var collection = db.collection('participants');
    // Helper function to add or update the document for a user
    Future<void> addOrUpdateUser(
        String userId, String otherUser, String projectTitle) async {
      var userDoc = await collection.findOne(where.eq("id", userId));

      if (userDoc != null) {
        await collection.update(
            where.eq('id', userId),
            modify.push('projects',
                {'hostName': otherUser, 'projectTitle': projectTitle}));
        print('Project added successfully for $userId.');
      } else {
        await collection.insert({
          "id": userId,
          "projects": [
            {'hostName': otherUser, 'projectTitle': projectTitle}
          ]
        });
        print('New document created and project added for $userId.');
      }
    }

    // Add or update documents for both sender and receiver
    await addOrUpdateUser(notif["sender"], notif["reciver"], notif["project"]);
    await addOrUpdateUser(notif["reciver"], notif["reciver"], notif["project"]);
    db.close();
  }

  // Updates the locally stored requested data.
  static Future<List<Map<dynamic, dynamic>>> updateLocalRequested() async {
    final db = await MongoDb().getConnection();
    final requestedData = await db
        .collection("requestMessage")
        .find(where.eq("sender", data.hostemail))
        .toList();
    await db.close();
    return requestedData;
  }

  // Updates the locally stored received data.
  static Future<List<Map<dynamic, dynamic>>> updateLocalRecevied() async {
    final db = await MongoDb().getConnection();
    final requestedData = await db
        .collection("requestMessage")
        .find(where.eq("reciver", data.hostemail))
        .toList();
    await db.close();
    return requestedData;
  }

  // Checks if a request message already exists.
  static Future<bool> checkRequestMessg({
    required String mssg,
    required String project,
    required Map reciver,
    required String sender,
  }) async {
    final db = await MongoDb().getConnection();
    final result = await db
        .collection("requestMessage")
        .find(where
            .eq("sender", sender)
            .eq("reciver", reciver["id"])
            .eq("project", project))
        .toList();
    await db.close();
    return result.isNotEmpty;
  }

  // Deletes a request from the database.
  static Future<void> deleteRequest(Map request) async {
    final db = await MongoDb().getConnection();
    try {
      await db.collection("requestMessage").deleteMany({
        "sender": request["sender"],
        "project": request["project"],
        "reciver": request["reciver"]
      });
    } catch (e) {
      print("Unable to delete request: $e");
    } finally {
      await db.close();
    }
  }

  // Modifies user information in the database.
  Future<void> modifyUser(
    Db db,
    String email, {
    String? userDesc,
    String? github,
    String? linkedin,
    List? skills,
    List? projects,
  }) async {
    var modifier = modify;

    if (userDesc != null) {
      modifier = modifier.set('user_description', userDesc);
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

    if (modifier.map.isNotEmpty) {
      await db.collection("user_info").updateOne(
            where.eq('id', email),
            modifier,
          );
    }
  }

  // Updates skill suggestions in the database.
  Future<void> updateSkill(Db db, List<String> skillSuggestions) async {
    skillSuggestions = skillSuggestions.toSet().toList();
    await db.collection('availskill').updateOne(
          where.eq('type', 'skill'),
          modify.set('skills', skillSuggestions),
          upsert: true,
        );
  }

  // Fetches a list of user IDs from the database.
  Future<List> getIds(Db db) async {
    final obj = await db
        .collection("user_info")
        .find(where.sortBy('id').fields(['id']))
        .toList();
    return obj.map((ele) => ele['id']).toList();
  }

  // Adds a new user to the database.
  Future<void> addUser(Db db, String mail) async {
    print("successfull entered");
    if (await checkUserExists(db, mail)) {
      print("successfull checked");
      await db.collection("user_info").insert({
        "id": mail,
        "type": "user",
        "skill": [],
        'projects': [],
        'github': "",
        'linkedin': '',
        'likes': 0,
        'user_description': '',
      });
      print("successfull inserted");
      await db.collection("favorites").insert({"id": mail, "favorites": []});
    }
  }

  // Fetches requests by skill, sorted by user likes.
  Future<List<Map<String, dynamic>>> fetchRequestsBySkillSortedByLikes(
    Db db,
    String skill,
  ) async {
    final pipeline = [
      {
        '\$lookup': {
          'from': 'user_info',
          'localField': 'Hostname',
          'foreignField': 'id',
          'as': 'user_info',
        }
      },
      {'\$unwind': '\$user_info'},
      {
        '\$match': {
          'skills.skill': skill,
          'Hostname': {'\$ne': data.hostemail},
        }
      },
      {
        '\$sort': {'user_info.likes': -1}
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

    final result =
        await db.collection('requests').aggregateToStream(pipeline).toList();
    await db.close();
    return result;
  }

  // Updates the list of favorite users.
  static void updateFav(List<String> fav) async {
    final db = await MongoDb().getConnection();
    await db.collection("favorites").updateOne(
          where.eq("id", data.hostemail),
          modify.set("favorites", fav),
        );
    await db.close();
  }

  // Increments the number of likes for a user.
  Future<void> incrementLikes(Db db, String userId) async {
    await db.collection("user_info").updateOne(
          where.eq('id', userId),
          modify.inc('likes', 1),
        );
  }

  // Decrements the number of likes for a user.
  Future<void> decrementLikes(Db db, String userId) async {
    await db.collection("user_info").updateOne(
          where.eq('id', userId),
          modify.inc('likes', -1),
        );
  }

  // Adds or updates a request in the database.
  Future<void> addRequest(
    Db db,
    Request request,
    Request prev,
    bool status,
  ) async {
    final collection = db.collection('requests');
    var modifier = modify;

    if (status) {
      modifier = modifier
          .set('projectTitle', request.projectTitle)
          .set('projectDesc', request.projectDesc)
          .set('date', request.date)
          .set('skills', request.skills);
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

  // Checks if a user exists in the database.
  Future<bool> checkUserExists(Db db, String email) async {
    List<Map<String, dynamic>> obj =
        await db.collection("user_info").find(where.eq('id', email)).toList();
    if (obj.isNotEmpty) {
      try {
        var details = obj[0];
        print(details);
        data.user_desc = details["user_description"];
        data.linkedIn = details["linkedin"];
        data.github = details["github"];
        data.skills = details["skill"];
        data.projects = details["projects"];
        data.hostemail = details["id"];
      } catch (error) {
        print("this errror caused ************* ${error}");
      }
    }
    try {
      // db.close();
    } catch (e) {
      print("problem in close");
    }
    return obj.isEmpty;
  }

  static Future<List<Map<String, dynamic>>> getProjects(
      String hostemail) async {
    var k = await MongoDb().getConnection();
    var data = await k
        .collection("participants")
        .find(where.eq("id", hostemail))
        .toList();
    print(data);
    return data;
  }
}
