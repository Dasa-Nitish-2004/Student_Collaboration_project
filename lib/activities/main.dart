import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/activities/homePage.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  var loggedin = "";

  MyApp({super.key}) {
    checkLog();
    print("constructor called ${loggedin}");
  }

  void checkLog() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString("email") == null) {
      loggedin = "";
    } else {
      loggedin = prefs.getString("email")!;
    }
    print("check completed");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: loggedin == ""
          ? signInPage()
          : MyHomePage(
              title: 'Home',
            ),
    );
  }
}

class signInPage extends StatefulWidget {
  signInPage({super.key});

  @override
  State<signInPage> createState() => _signInPageState();
}

class _signInPageState extends State<signInPage> {
  late mongo.Db db;
  List data = [];
  // late final SharedPreferences prefs;

  void connect() async {
    db = await MongoDb().getConnection();
    fetchData();
  }

  void fetchData() async {
    data = await MongoDb().getIds(db);
    // print(data);
  }

  late GoogleSignIn _googleSignIn;

  Widget login_space = Container();
  var email = "";

  signIn() async {
    _googleSignIn = GoogleSignIn();
    try {
      var result = await _googleSignIn.signIn();
      email = result!.email;

      if (!data.contains(email)) {
        _googleSignIn.disconnect();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("failed to Sign In please Register the account"),
            duration: Duration(seconds: 2),
          ),
        );
        email = "";
      } else {
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("successfull signed in $email"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return MyHomePage(
              title: '',
            );
          },
        ));
      }
    } catch (error) {
      print(error);
    } finally {
      setState(() {});
    }
  }

  signOut() => _googleSignIn.disconnect();

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
                  child: Text("Sign In")),
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      login_space = registerEmail();
                    });
                  },
                  child: Text("Register")),
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
          color: Colors.deepPurple,
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
          ElevatedButton(onPressed: signIn, child: Text("Register with Mail")),
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
          color: Colors.deepPurple,
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

// const MyHomePage(title: 'Flutter Demo Home Page'),