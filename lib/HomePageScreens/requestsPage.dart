import 'package:flutter/material.dart';
import 'package:scolab/HomePageScreens/addRequestPage.dart';
import 'package:scolab/request_bluePrint.dart';

class RequestsPage extends StatefulWidget {
  RequestsPage({super.key});
  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<Request> request = [];

  void addRequest(Request k) {
    setState(() {
      print("request added");
      request.add(k);
    });
  }

  void _addRequest() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return AddRequestPage(addRequest);
      },
    );
  }

  Widget reqcard(Request req) {
    return Card(
      elevation: 4,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              req.projectTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(req.projectDesc),
            SizedBox(height: 8),
            Text('Skills: ${req.skills.map((s) => s['skill']).join(', ')}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("build called :___?>${request.length}");
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: request.map((element) => reqcard(element)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addRequest,
      ),
    );
  }
}
