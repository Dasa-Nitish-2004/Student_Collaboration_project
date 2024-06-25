import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/data.dart' as datafile;
// import 'package:hive/hive.dart';
import 'package:scolab/DatabaseService/HiveService.dart';

class User_info_Screen extends StatefulWidget {
  final String hostName, project;

  User_info_Screen({Key? key, required this.hostName, required this.project})
      : super(key: key);

  @override
  State<User_info_Screen> createState() => _User_info_ScreenState();
}

class _User_info_ScreenState extends State<User_info_Screen> {
  late bool fav;
  TextEditingController messageController = TextEditingController();
  var result;
  bool check = false;
  int favChange = 0; // 0 no change. 1 initial liked. 2 initial unliked
  Widget k = Center(
    child: CircularProgressIndicator(),
  );

  @override
  void dispose() async {
    messageController.dispose();
    super.dispose();
    if (favChange == 0) {
      return;
    }
    var db = await MongoDb().getConnection();
    if (favChange == 1) {
      if (fav == false) {
        MongoDb().decrementLikes(db, widget.hostName);
      }
    } else {
      if (fav == true) {
        MongoDb().incrementLikes(db, widget.hostName);
      }
    }
    HiveService.updateFav();
    db.close();
  }

  @override
  void initState() {
    super.initState();
    fav = HiveService.isUserLiked(widget.hostName);
    if (fav) {
      favChange = 1;
    } else {
      favChange = 2;
    }
  }

  Future<void> getConnected() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('send request'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  maxLines: 4,
                  minLines: 1,
                  controller: messageController,
                  decoration: const InputDecoration(
                      hintText: "enter the request message"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                if (messageController.text.isEmpty ||
                    messageController.text.trim() == "") {
                  return;
                } else {
                  MongoDb.sendConnectRequest(
                      mssg: messageController.text,
                      project: widget.project,
                      sender: datafile.hostemail,
                      reciver: result);
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.send),
              color: Theme.of(context).colorScheme.inversePrimary,
            )
          ],
        );
      },
    );
  }

  void getResult() async {
    if (check == false) {
      var db = await MongoDb().getConnection();
      result = await datafile.getUserData(widget.hostName);
      check = true;
      k = ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            'User ID: ${result['id']}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Description: ${result['user_description']}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            'Skills:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...result['skill'].map<Widget>((skill) {
            return ListTile(
              title: Text(skill['skill']),
              subtitle: Text(skill['description']),
            );
          }).toList(),
          SizedBox(height: 16),
          Text(
            'Projects:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...result['projects'].map<Widget>((project) {
            return ListTile(
              title: Text(project['project']),
              subtitle: Text(project['description']),
            );
          }).toList(),
          SizedBox(height: 16),
          Text(
            'GitHub: ${result['github']}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'LinkedIn: ${result['linkedin']}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Likes: ${result['likes']}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 30,
          ),
          TextButton(
            child: Text("connect"),
            onPressed: getConnected,
          ),
          SizedBox(
            height: 30,
          ),
        ],
      );
      setState(() {});
    }
  }

  void toggleFavorite() {
    setState(() {
      fav = !fav;
      if (fav) {
        HiveService.addLikedUser(widget.hostName);
      } else {
        HiveService.removeLikedUser(widget.hostName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getResult();
    return Scaffold(
      appBar: AppBar(
        title: Text("User Info"),
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(
              (fav ? Icons.favorite : Icons.favorite_border),
              color: Colors.red[900],
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: k,
    );
  }
}
