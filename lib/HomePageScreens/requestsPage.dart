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
    // _loadRequests();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  // Show loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  // Load requests from the server
  Future<void> _loadRequests() async {
    _showLoadingDialog();
    try {
      await addResponse();
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog("Error loading requests: $error");
      }
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  // Add a new request
  void addRequest({Request? k}) {
    setState(() {
      req.add(k!);
    });
  }

  // Delete a request
  void deleteRequest({Request? k}) {
    setState(() {
      req.remove(k!);
      deleteResponse(k!);
    });
  }

  // Open the AddRequestPage for adding or editing a request
  void _openAddRequestPage({Request? k}) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return AddRequestPage(addRequest, k: k);
      },
    );
  }

  // Build a request card
  Widget _buildRequestCard(Request req) {
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
                    req.skills
                        .map((s) => "${s['skill']} :-> ${s['description']}")
                        .join(',\n'),
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
                    _openAddRequestPage(k: req);
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
            child: _buildRequestCard(req[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _openAddRequestPage(),
      ),
    );
  }
}
