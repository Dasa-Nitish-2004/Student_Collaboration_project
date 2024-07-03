import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/activities/HomePage.dart';
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
  await Hive.openBox('My_Projects');

  runApp(const MyApp());
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
        InternetConnection().onStatusChange.listen((event) {
      setState(() {
        isConnected = event == InternetStatus.connected;
        if (isConnected) {
          checkLog();
        }
      });
    });
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
      var db = await MongoDb().getConnection();
      try {
        if (await MongoDb().checkUserExists(db, email)) {
          await prefs.setString('email', "");
          loggedin = "";
        } else {
          await prefs.setString('email', email);
          loggedin = email;
          dataFile.hostemail = email;
        }
      } catch (error) {
        db.close();
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
              // : const Center(
              //     child: CircularProgressIndicator(),
              //   )
              : Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/imgs/appIcon.png"),
                          radius: 50,
                        ),
                        Text("SCOLAB"),
                      ],
                    ),
                  ),
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
  late GoogleSignIn _googleSignIn;
  Widget login_space = Container();
  var email = "";

  @override
  void initState() {
    login_space = signInEmail();
    connect();
    try {
      signOut();
    } catch (e) {}
    super.initState();
  }

  void connect() async {
    try {
      db = await MongoDb().getConnection();
    } catch (e) {
      print("Error connecting to MongoDB: $e");
    }
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  Future<void> registerUser() async {
    _googleSignIn = GoogleSignIn();
    try {
      var result = await _googleSignIn.signIn();
      var email = result!.email;
      print(email);
      await MongoDb().addUser(db, email);
      signOut();
      showSnackBar("Successfully registered in $email");
    } catch (error) {
      showSnackBar("Unsuccessful to register: $error, try again");
      signOut();
    } finally {
      setState(() {});
    }
  }

  Future<void> signIn() async {
    _googleSignIn = GoogleSignIn();
    try {
      var result = await _googleSignIn.signIn();
      email = result!.email;
      showLoadingDialog();
      if (!await MongoDb().checkUserExists(db, email)) {
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        dataFile.hostemail = email;
        Navigator.pop(context);
        showSnackBar("Successfully signed in $email");
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return SkillPage(title: 'Info & Skill');
          },
        ));
      } else {
        signOut();
        Navigator.pop(context);
        showSnackBar("Failed to Sign In. Please register the account.");
        email = "";
      }
    } catch (error) {
      signOut();
      showSnackBar("${error}");
    } finally {
      setState(() {});
    }
  }

  void signOut() {
    _googleSignIn.signOut();
    _googleSignIn.disconnect();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
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
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    login_space = signInEmail();
                  });
                },
                child: Text("Sign In"),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    login_space = registerEmail();
                  });
                },
                child: Text("Register"),
              ),
            ],
          ),
          SizedBox(height: 20),
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
            onPressed: registerUser,
            child: Text("Register with Mail"),
          ),
          SizedBox(height: 20),
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
            onPressed: signIn,
            child: Text("Sign with Registered Mail"),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
