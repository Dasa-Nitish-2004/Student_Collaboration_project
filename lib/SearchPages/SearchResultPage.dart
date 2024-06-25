import 'package:flutter/material.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/activities/User_info_Screen.dart';

class SearchResultPage extends StatefulWidget {
  final String skill;
  SearchResultPage(this.skill, {super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  Future<List<Map<String, dynamic>>> getResult() async {
    var db = await MongoDb().getConnection();
    var result =
        await MongoDb().fetchRequestsBySkillSortedByLikes(db, widget.skill);
    await db.close();
    return result;
  }

  Widget buildCard(Map<String, dynamic> request) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return User_info_Screen(
                hostName: request['Hostname'],
                project: request['projectTitle']);
          },
        ));
      },
      child: Card(
        elevation: 4,
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request['projectTitle'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(request['projectDesc']),
              SizedBox(height: 8),
              Text('Hostname: ${request['Hostname']}'),
              SizedBox(height: 8),
              Text('Date: ${request['date']}'),
              SizedBox(height: 8),
              Text(
                  'Skills: ${request['skills'].map((s) => "${s['skill']}: ${s['description']}").join(', \n')}'),
              SizedBox(height: 8),
              Text('Likes: ${request['user_likes']}'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Result"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getResult(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No results found."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: buildCard(snapshot.data![index]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
