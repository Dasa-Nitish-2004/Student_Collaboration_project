import 'package:flutter/material.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/data.dart';

class ProjectTeams extends StatefulWidget {
  @override
  State<ProjectTeams> createState() => _ProjectTeamsState();
}

class _ProjectTeamsState extends State<ProjectTeams> {
  @override
  List k = [];
  void initState() {
    // TODO: implement initState
    _initializeDocument();
    super.initState();
  }

  void _initializeDocument() async {
    try {
      k = (await MongoDb.getProjects(hostemail))[0]["projects"];
    } catch (e) {
      print("error in type caste : ${e}");
    }
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.replay),
      ),
      body: k.isEmpty
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text("nothing to show"),
              ],
            ))
          : ListView.builder(
              itemBuilder: (context, index) {
                return Card(
                  child: Text("${k[index]}"),
                );
              },
              itemCount: k.length,
            ),
    );
  }
}
