import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/activities/HomePage.dart';
// import 'package:scolab/activities/notificationScreen.dart';
import 'package:scolab/activities/skillsPage.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scolab/data.dart' as dataFile;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('liked_users');
  await Hive.openBox('Requested_Requests');
  await Hive.openBox('Recived_Requests');

  runApp(const MyApp());

  // runApp(MaterialApp(home: NotificationScreen()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String loggedin = "";
  bool status = false;
  bool isConnected = false;
  StreamSubscription? _internetConnectionStreamSubscription;

  @override
  void initState() {
    super.initState();

    _internetConnectionStreamSubscription =
        InternetConnection().onStatusChange.listen(
      (event) {
        switch (event) {
          case InternetStatus.connected:
            setState(() {
              isConnected = true;
              checkLog();
            });
            break;
          case InternetStatus.disconnected:
            setState(() {
              isConnected = false;
            });
            break;
          default:
            setState(() {
              isConnected = false;
            });
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  void checkLog() async {
    var prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    if (email == null || email.isEmpty) {
      loggedin = "";
    } else {
      if (await MongoDb()
          .checkUserExists(await MongoDb().getConnection(), email)) {
        await prefs.setString('email', "");
        loggedin = "";
      } else {
        loggedin = email;
        dataFile.hostemail = email;
      }
    }
    setState(() {
      status = true;
    }); // Update the UI after checking the login status
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: isConnected
          ? status
              ? (loggedin.isEmpty ? signInPage() : HomeScreen())
              : const Center(
                  child: CircularProgressIndicator(),
                )
          : const Center(
              child: Scaffold(
                body: Center(
                  child: Text("Internet not Connected"),
                ),
              ),
            ),
    );
  }
}

class signInPage extends StatefulWidget {
  const signInPage({super.key});

  @override
  State<signInPage> createState() => _signInPageState();
}

class _signInPageState extends State<signInPage> {
  late mongo.Db db;
  List data = [];
  late GoogleSignIn _googleSignIn;
  Widget login_space = Container();
  var email = "";

  void connect() async {
    db = await MongoDb().getConnection();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  registerUser() async {
    _googleSignIn = GoogleSignIn();
    try {
      var result = await _googleSignIn.signIn();
      email = result!.email;
      MongoDb().addUser(db, email);
      signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully registered in $email"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unsuccessful to register : $email, try again"),
          duration: Duration(seconds: 2),
        ),
      );
      signOut();
      // print(error);
    } finally {
      setState(() {});
    }
  }

  signIn() async {
    _googleSignIn = GoogleSignIn();
    try {
      var result = await _googleSignIn.signIn();
      email = result!.email;
      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      if (!await MongoDb()
          .checkUserExists(await MongoDb().getConnection(), email)) {
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        dataFile.hostemail = email;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully signed in $email"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return SkillPage(
              title: 'Info & Skill',
            );
          },
        ));
      } else {
        signOut();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to Sign In. Please register the account."),
            duration: Duration(seconds: 2),
          ),
        );
        email = "";
      }
    } catch (error) {
      signOut();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Check internet connectivity"),
        duration: Duration(seconds: 3),
      ));
    } finally {
      setState(() {});
    }
  }

  signOut() {
    _googleSignIn.signOut();
    _googleSignIn.disconnect();
  }

  @override
  void initState() {
    login_space = signInEmail();
    connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("SCOLAB"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      login_space = signInEmail();
                    });
                  },
                  child: Text(
                    "Sign In",
                  )),
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      login_space = registerEmail();
                    });
                  },
                  child: Text(
                    "Register",
                  )),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          login_space,
        ],
      ),
    );
  }

  Widget registerEmail() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Image.asset(
            "assets/imgs/googleLogo.png",
            height: 200,
            width: double.infinity,
          ),
          ElevatedButton(
              onPressed: registerUser, child: Text("Register with Mail")),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget signInEmail() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Image.asset(
            "assets/imgs/googleLogo.png",
            height: 200,
            width: double.infinity,
          ),
          ElevatedButton(
              onPressed: signIn, child: Text("Sign with Registered Mail")),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
