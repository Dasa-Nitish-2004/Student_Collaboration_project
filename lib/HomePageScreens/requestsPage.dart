import 'package:flutter/material.dart';
import 'package:scolab/HomePageScreens/addRequestPage.dart';
import 'package:scolab/data.dart';
import 'package:scolab/request_bluePrint.dart';

class RequestsPage extends StatefulWidget {
  RequestsPage({super.key});
  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoadingDialog();
      addResponse().then((_) {
        if (mounted) {
          Navigator.pop(context);
          setState(() {});
        }
      }).catchError((error) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    });
  }

  void addRequest({Request? k}) {
    setState(() {
      req.add(k!);
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void deleteRequest({Request? k}) {
    setState(() {
      req.remove(k!);
      deleteResponse(k!);
    });
  }

  void _addRequest({Request? k}) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        if (k == null) {
          return AddRequestPage(addRequest);
        } else {
          return AddRequestPage(addRequest, k: k);
        }
      },
    );
  }

  Widget reqcard(Request req) {
    return Card(
      elevation: 4,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              // Wrap the Column with Expanded
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.projectTitle,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    req.projectDesc,
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${req.skills.map((s) => "${s['skill']} :-> ${s['description']}").join(',\n')}',
                    softWrap: true,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    _addRequest(k: req);
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    deleteRequest(k: req);
                  },
                  icon: Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: req.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: reqcard(req[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addRequest(),
      ),
    );
  }
}
