import 'package:hive/hive.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';

class HiveService {
  static Box get likedUsersBox => Hive.box('liked_users');
  static Box get requestedRequestsBox => Hive.box('Requested_Requests');
  static Box get receivedRequestsBox => Hive.box('Recived_Requests');

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

      print(req.length);
      for (var element in req) {
        element["_id"] = "";
        print(element);
      }
      requestedRequestsBox.put('Requested_Requests', req);
    } catch (e) {
      print("errror : ${e}");
    }
  }

  static Future<void> updateReceivedNotification() async {
    try {
      List<Map<dynamic, dynamic>> req = await MongoDb.updateLocalRecevied();

      print(req.length);
      for (var element in req) {
        element["_id"] = "";
        print(element);
      }
      receivedRequestsBox.put('Recived_Requests', req);
    } catch (e) {
      print("errror : ${e}");
    }
  }

  static List<Map> getRequestedRequests() {
    print("****************getRequestedRequests called*******************");
    var requestedRequests = List<Map<dynamic, dynamic>>.from(
        requestedRequestsBox.get('Requested_Requests',
            defaultValue: <Map<dynamic, dynamic>>[]));
    print(requestedRequests);
    return requestedRequests;
  }

  static void addRequestedRequest(Map<dynamic, dynamic> entry) {
    print("****************addRequestedRequest called*******************");
    var requestedRequests = List<Map<dynamic, dynamic>>.from(
        requestedRequestsBox.get('Requested_Requests',
            defaultValue: <Map<dynamic, dynamic>>[]));
    requestedRequests.add(entry);
    print(requestedRequests);
    requestedRequestsBox.put('Requested_Requests', requestedRequests);
  }

  static List<Map<dynamic, dynamic>> getReceivedRequests() {
    print("****************getReceivedRequests called*******************");
    var receivedRequests = List<Map<dynamic, dynamic>>.from(receivedRequestsBox
        .get('Recived_Requests', defaultValue: <Map<dynamic, dynamic>>[]));
    print(receivedRequests);
    return receivedRequests;
  }

  static void addReceivedRequest(Map<dynamic, dynamic> entry) {
    print("****************addReceivedRequest called*******************");
    var receivedRequests = List<Map<dynamic, dynamic>>.from(receivedRequestsBox
        .get('Recived_Requests', defaultValue: <Map<dynamic, dynamic>>[]));
    receivedRequests.add(entry);
    print(receivedRequests);
    receivedRequestsBox.put('Recived_Requests', receivedRequests);
  }
}
