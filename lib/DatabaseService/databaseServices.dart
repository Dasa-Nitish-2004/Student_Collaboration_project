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

  Future<void> modifyUser(Db db, String email,
      {String? user_desc,
      String? github,
      String? linkedin,
      List? skills,
      List? projects}) async {
    print('User Description: $user_desc');
    print('GitHub: $github');
    print('LinkedIn: $linkedin');
    print('Skills: $skills');
    print('Projects: $projects');

    // Start with an empty modifier builder
    var modifier = modify;

    // Add each field to the modifier if it is not null
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

  Future<List> getIds(Db db) async {
    List obj;
    List data = [];
    var movies = await db.collection("user_info");
    print("accepted");
    obj = (await movies.find(where.sortBy('id').fields(['id'])).toList());
    obj.forEach(
      (ele) {
        data.add(ele['id']);
      },
    );
    print(data);
    return data;
  }

  void addUser(Db db, String mail) async {
    var user = await db.collection("user_info");
    // await user.insert({
    //   "id": "mail",
    //   "type": "user",
    //   "skill": {'python': 'basics of python', 'flutter': 'basic projects'},
    //   'projects': {
    //     'student_attendence': {
    //       'description': 'general purpose attendence',
    //       'link': "www.google.com"
    //     },
    //   },
    //   'github': "dasa nitish 2004",
    //   'linkedin': 'dasa nitish',
    //   'user_description': 'I am good and passinate guy',
    // });
    if (await checkUserExists(db, mail)) {
      await user.insert({
        "id": mail,
        "type": "user",
        "skill": [],
        'projects': [],
        'github': "",
        'linkedin': '',
        'user_description': '',
      });
    }
  }

  Future checkUserExists(Db db, String email) async {
    List obj;
    var movies = await db.collection("user_info");
    print("in check user !!!!!!!!!!!!!!!!!!!!!!!!!!!");
    obj = (await movies.find(where.eq('id', email)).toList());
    if (obj.isEmpty) {
      return true; // user doesn't exists free to create user
    }
    return false;
  }
}
