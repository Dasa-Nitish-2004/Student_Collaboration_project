import 'package:flutter/material.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/data.dart' as datafile;
import 'package:scolab/DatabaseService/HiveService.dart';

class User_info_Screen extends StatefulWidget {
  final String hostName;
  final String project;

  User_info_Screen({Key? key, required this.hostName, required this.project})
      : super(key: key);

  @override
  State<User_info_Screen> createState() => _User_info_ScreenState();
}

class _User_info_ScreenState extends State<User_info_Screen> {
  late bool fav;
  final TextEditingController messageController = TextEditingController();
  var result;
  bool check = false;
  int favChange = 0; // 0 no change. 1 initial liked. 2 initial unliked
  Widget loadingWidget = Center(child: CircularProgressIndicator());
  bool isSendingRequest = false;

  @override
  void dispose() async {
    messageController.dispose();
    super.dispose();
    await _updateLikes();
  }

  Future<void> _updateLikes() async {
    if (favChange == 0) return;

    var db = await MongoDb().getConnection();
    if (favChange == 1 && !fav) {
      await MongoDb().decrementLikes(db, widget.hostName);
    } else if (favChange == 2 && fav) {
      await MongoDb().incrementLikes(db, widget.hostName);
    }
    HiveService.updateFav();
    db.close();
  }

  @override
  void initState() {
    super.initState();
    fav = HiveService.isUserLiked(widget.hostName);
    favChange = fav ? 1 : 2;
  }

  Future<void> _getConnected() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Send Request'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      maxLines: 4,
                      minLines: 1,
                      controller: messageController,
                      decoration: const InputDecoration(
                          hintText: "Enter the request message"),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                isSendingRequest
                    ? Center(child: CircularProgressIndicator())
                    : IconButton(
                        onPressed: () async {
                          if (messageController.text.trim().isEmpty) return;

                          setState(() {
                            isSendingRequest = true;
                          });

                          await MongoDb.sendConnectRequest(
                            mssg: messageController.text,
                            project: widget.project,
                            sender: datafile.hostemail,
                            reciver: result,
                          );

                          setState(() {
                            isSendingRequest = false;
                          });

                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.send),
                        color: Theme.of(context).colorScheme.inversePrimary,
                      )
              ],
            );
          },
        );
      },
    );
  }

  void _getResult() async {
    if (check) return;

    var db = await MongoDb().getConnection();
    result = await datafile.getUserData(widget.hostName);
    check = true;
    loadingWidget = _buildUserInfo(result);
    setState(() {});
  }

  Widget _buildUserInfo(var result) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        _buildUserInfoText('User ID: ${result['id']}', 18, FontWeight.bold),
        SizedBox(height: 16),
        _buildUserInfoText('Description: ${result['user_description']}', 16),
        SizedBox(height: 16),
        _buildUserInfoText('Skills:', 18, FontWeight.bold),
        ...result['skill'].map<Widget>((skill) {
          return ListTile(
            title: Text(skill['skill']),
            subtitle: Text(skill['description']),
          );
        }).toList(),
        SizedBox(height: 16),
        _buildUserInfoText('Projects:', 18, FontWeight.bold),
        ...result['projects'].map<Widget>((project) {
          return ListTile(
            title: Text(project['project']),
            subtitle: Text(project['description']),
          );
        }).toList(),
        SizedBox(height: 16),
        _buildUserInfoText('GitHub: ${result['github']}', 16),
        SizedBox(height: 8),
        _buildUserInfoText('LinkedIn: ${result['linkedin']}', 16),
        SizedBox(height: 8),
        _buildUserInfoText('Likes: ${result['likes']}', 16),
        SizedBox(height: 30),
        TextButton(
          child: Text("Connect"),
          onPressed: _getConnected,
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildUserInfoText(String text, double fontSize,
      [FontWeight fontWeight = FontWeight.normal]) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  void _toggleFavorite() {
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
    _getResult();
    return Scaffold(
      appBar: AppBar(
        title: Text("User Info"),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              fav ? Icons.favorite : Icons.favorite_border,
              color: Colors.red[900],
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: loadingWidget,
    );
  }
}
