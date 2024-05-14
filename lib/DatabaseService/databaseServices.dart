import 'package:mongo_dart/mongo_dart.dart';

class MongoDb {
  Future<Db> getConnection() async {
    String pass = "dasa6302081627";
    var db = await Db.create(
        "mongodb+srv://dasanitish2004:$pass@userdata.marephd.mongodb.net/sample_mflix?retryWrites=true&w=majority&appName=UserData");
    await db.open();
    return db;
  }

  Future<List> getMovie(Db db) async {
    List data = [];
    var movies = await db.collection("movies");
    data = await movies
        .find(where.sortBy('title').fields(['title']).skip(20).limit(20))
        .toList();

    return data;
  }

  Future<List> getIds(Db db) async {
    List obj;
    List data = [];
    var movies = await db.collection("users");
    obj = (await movies.find(where.sortBy('email').fields(['email'])).toList());
    obj.forEach(
      (ele) {
        data.add(ele['email']);
      },
    );
    // print(data);
    return data;
  }
}
