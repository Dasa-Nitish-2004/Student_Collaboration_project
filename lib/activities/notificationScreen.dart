import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import "package:scolab/DatabaseService/HiveService.dart";
import 'package:scolab/activities/User_info_Screen.dart';

List<Map> recived_nof = [];
List<Map> requested_nof = [];

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Requested(),
              flex: 1,
            ),
            Expanded(
              child: RecivedNotification(),
              flex: 1,
            )
          ],
        ),
      ),
    );
  }
}

class Requested extends StatefulWidget {
  @override
  State<Requested> createState() => _RequestedState();
}

class _RequestedState extends State<Requested> {
  @override
  void initState() {
    super.initState();
  }

  bool is_RequestClicked = false;

  @override
  Widget build(BuildContext context) {
    requested_nof = HiveService.getRequestedRequests();
    print(requested_nof);
    return Column(
      children: [
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Requested Notification",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            is_RequestClicked
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : IconButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          is_RequestClicked = true;
                        });
                        await HiveService.updateRequestedNotification();
                        setState(() {
                          is_RequestClicked = false;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("error in fetching")));
                      } finally {}

                      setState(() {});
                    },
                    icon: Icon(Icons.replay_rounded),
                  )
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: requested_nof.length,
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "To : ${requested_nof[index]["reciver"]}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            "Project : ${requested_nof[index]["project"]}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            "Date : ${requested_nof[index]["date"].toString().split(" ")[0]}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            "message : ${requested_nof[index]["message"]}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: () async {
                            await HiveService.deleteRequestedRequests(
                                requested_nof[index]);
                            setState(() {});
                          },
                          icon: Icon(Icons.delete)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecivedNotification extends StatefulWidget {
  @override
  State<RecivedNotification> createState() => _RecivedNotification();
}

class _RecivedNotification extends State<RecivedNotification> {
  @override
  void initState() {
    super.initState();
  }

  bool is_AcceptedClicked = false;
  bool _isRecivedClicked = false;
  @override
  Widget build(BuildContext context) {
    recived_nof = HiveService.getReceivedRequests();
    return Column(
      children: [
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Recieved Notification",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _isRecivedClicked
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : IconButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          _isRecivedClicked = true;
                        });
                        await HiveService.updateReceivedNotification();
                        setState(() {
                          _isRecivedClicked = false;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("error in fetching")));
                      } finally {}

                      setState(() {});
                    },
                    icon: Icon(Icons.replay))
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recived_nof.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  print("clicked");
                  try {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return User_info_Screen(
                            hostName: recived_nof[index]["sender"],
                            project: recived_nof[index]["project"]);
                      },
                    ));
                  } catch (e) {
                    print(e.toString());
                  }
                },
                child: Card(
                  elevation: 4,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
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
                                "Sended : ${recived_nof[index]["sender"]}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                "Project : ${recived_nof[index]["project"]}",
                                softWrap: true,
                                overflow: TextOverflow.clip,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                "Date : ${recived_nof[index]["date"].toString().split(" ")[0]}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                "message : ${recived_nof[index]["message"]}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        is_AcceptedClicked
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        is_AcceptedClicked = true;
                                      });
                                      await HiveService.deleteRecivedRequest(
                                          recived_nof[index], true);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "connected succesfully!")));
                                      setState(() {
                                        is_AcceptedClicked = false;
                                      });
                                    },
                                    icon: Icon(Icons.check),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await HiveService.deleteRecivedRequest(
                                          recived_nof[index], false);
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.close),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
