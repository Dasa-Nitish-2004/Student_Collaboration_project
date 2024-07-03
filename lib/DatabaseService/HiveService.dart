import 'package:hive/hive.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';

class HiveService {
  static Box get likedUsersBox => Hive.box('liked_users');
  static Box get requestedRequestsBox => Hive.box('Requested_Requests');
  static Box get receivedRequestsBox => Hive.box('Recived_Requests');
  static Box get my_ProjectBox => Hive.box('My_Projects');

  static void removeLikedUser(String userId) {
    var likedUsers = List<String>.from(
        likedUsersBox.get('liked_users', defaultValue: <String>[]));
    likedUsers.remove(userId);
    likedUsersBox.put('liked_users', likedUsers);
  }

  static bool isUserLiked(String userId) {
    var likedUsers = List<String>.from(
        likedUsersBox.get('liked_users', defaultValue: <String>[]));
    return likedUsers.contains(userId);
  }

  static void updateFav() async {
    var likedUsers = List<String>.from(
        likedUsersBox.get('liked_users', defaultValue: <String>[]));
    MongoDb.updateFav(likedUsers);
  }

  static void addLikedUser(String userId) {
    var likedUsers = List<String>.from(
        likedUsersBox.get('liked_users', defaultValue: <String>[]));
    if (!likedUsers.contains(userId)) {
      likedUsers.add(userId);
      likedUsersBox.put('liked_users', likedUsers);
    }
  }

  static Future<void> updateRequestedNotification() async {
    try {
      List<Map<dynamic, dynamic>> req = await MongoDb.updateLocalRequested();

      for (var element in req) {
        element["_id"] = "";
      }
      requestedRequestsBox.put('Requested_Requests', req);
    } catch (e) {
      print("errror : ${e}");
    }
  }

  static Future<void> updateReceivedNotification() async {
    try {
      List<Map<dynamic, dynamic>> req = await MongoDb.updateLocalRecevied();

      for (var element in req) {
        element["_id"] = "";
      }
      receivedRequestsBox.put('Recived_Requests', req);
    } catch (e) {
      print("errror : ${e}");
    }
  }

  static Future<void> deleteRequestedRequests(Map notification) async {
    var requestedRequests = List<Map<dynamic, dynamic>>.from(
        requestedRequestsBox.get('Requested_Requests',
            defaultValue: <Map<dynamic, dynamic>>[]));

    requestedRequests.remove(notification);
    requestedRequestsBox.put("Requested_Requests", requestedRequests);

    MongoDb.deleteRequest(notification);
  }

  static Future<void> deleteRecivedRequest(
      Map notification, bool isConnected) async {
    var recivedRequests = List<Map<dynamic, dynamic>>.from(receivedRequestsBox
        .get('Recived_Requests', defaultValue: <Map<dynamic, dynamic>>[]));

    recivedRequests.remove(notification);
    receivedRequestsBox.put("Recived_Requests", recivedRequests);

    if (isConnected) {
      MongoDb.addParticipant(notification);
    }
    MongoDb.deleteRequest(notification);
  }

  static void addRequestedRequest(Map<dynamic, dynamic> entry) {
    var requestedRequests = List<Map<dynamic, dynamic>>.from(
        requestedRequestsBox.get('Requested_Requests',
            defaultValue: <Map<dynamic, dynamic>>[]));
    requestedRequests.add(entry);
    requestedRequestsBox.put('Requested_Requests', requestedRequests);
  }

  static List<Map<dynamic, dynamic>> getReceivedRequests() {
    var receivedRequests = List<Map<dynamic, dynamic>>.from(receivedRequestsBox
        .get('Recived_Requests', defaultValue: <Map<dynamic, dynamic>>[]));
    print(receivedRequests);
    return receivedRequests;
  }

  static List<Map> getRequestedRequests() {
    var requestedRequests = List<Map<dynamic, dynamic>>.from(
        requestedRequestsBox.get('Requested_Requests',
            defaultValue: <Map<dynamic, dynamic>>[]));
    return requestedRequests;
  }

  static void addReceivedRequest(Map<dynamic, dynamic> entry) {
    var receivedRequests = List<Map<dynamic, dynamic>>.from(receivedRequestsBox
        .get('Recived_Requests', defaultValue: <Map<dynamic, dynamic>>[]));
    receivedRequests.add(entry);
    receivedRequestsBox.put('Recived_Requests', receivedRequests);
  }
}
