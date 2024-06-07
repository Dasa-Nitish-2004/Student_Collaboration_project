// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:provider/provider.dart';
// import 'package:scolab/DatabaseService/databaseServices.dart';
// import 'package:scolab/activities/HomePage.dart';
// import 'package:scolab/activities/skillsPage.dart';
// import 'package:mongo_dart/mongo_dart.dart' as mongo;
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   var loggedin = "";

//   MyApp({super.key}) {
//     checkLog();
//     print("constructor called ${loggedin}");
//   }

//   void checkLog() async {
//     var prefs = await SharedPreferences.getInstance();
//     if (prefs.getString("email") == null || prefs.getString("email") == "") {
//       loggedin = "";
//     } else {
//       print(
//           "saved email found^^^^^^^^^^^^^^^^${prefs.getString("email")}^^^^^^^^^^^^^");
//       loggedin = await prefs.getString("email")!;
//       if (await MongoDb()
//           .checkUserExists(await MongoDb().getConnection(), loggedin)) {
//         await prefs.setString('email', "");
//         loggedin = "";
//       }
//     }
//     print("check completed");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         home: loggedin == "" ? signInPage() : HomeScreen());
//   }
// }

// class signInPage extends StatefulWidget {
//   signInPage({super.key});

//   @override
//   State<signInPage> createState() => _signInPageState();
// }

// class _signInPageState extends State<signInPage> {
//   late mongo.Db db;
//   List data = [];
//   // late final SharedPreferences prefs;

//   void connect() async {
//     db = await MongoDb().getConnection();
//     fetchData();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     db.close();
//     super.dispose();
//   }

//   void fetchData() async {
//     data = await MongoDb().getIds(db);
//     // print(data);
//   }

//   late GoogleSignIn _googleSignIn;

//   Widget login_space = Container();
//   var email = "";

//   registerUser() async {
//     _googleSignIn = GoogleSignIn();
//     try {
//       var result = await _googleSignIn.signIn();
//       email = result!.email;
//       MongoDb().addUser(db, email);
//       signOut();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("successfull registered in $email"),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Unsuccessfull to register :$email try again"),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       signOut();
//       print(error);
//     } finally {
//       setState(() {});
//     }
//   }

//   signIn() async {
//     _googleSignIn = GoogleSignIn();
//     try {
//       var result = await _googleSignIn.signIn();
//       email = result!.email;
//       showDialog(
//         context: context,
//         builder: (context) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         },
//       );
//       if (data.contains(email) ||
//           !await MongoDb()
//               .checkUserExists(await MongoDb().getConnection(), email)) {
//         var prefs = await SharedPreferences.getInstance();
//         await prefs.setString('email', email);
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("successfull signed in $email"),
//             duration: Duration(seconds: 2),
//           ),
//         );
//         Navigator.of(context).pushReplacement(MaterialPageRoute(
//           builder: (context) {
//             return SkillPage(
//               title: 'Info & Skill',
//             );
//           },
//         ));
//       } else {
//         signOut();
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("failed to Sign In please Register the account"),
//             duration: Duration(seconds: 2),
//           ),
//         );
//         email = "";
//       }
//     } catch (error) {
//       signOut();
//       print("error : ***${error}***");
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Check internet connectivity"),
//         duration: Duration(seconds: 3),
//       ));
//     } finally {
//       setState(() {});
//     }
//   }

//   signOut() {
//     _googleSignIn.signOut();
//   }

//   @override
//   void initState() {
//     login_space = signInEmail();
//     connect();
//     super.initState();
//   }

//   var sharedPref = "";

//   void lode() async {
//     var pref = await SharedPreferences.getInstance();
//     sharedPref = pref.getString("email")!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     lode();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text("SCOLAB"),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text("<<<<<<${sharedPref}>>>>>>"),
//           SizedBox(
//             height: 20,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       login_space = signInEmail();
//                     });
//                   },
//                   child: Text("Sign In")),
//               SizedBox(
//                 width: 20,
//               ),
//               ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       login_space = registerEmail();
//                     });
//                   },
//                   child: Text("Register")),
//             ],
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           login_space,
//         ],
//       ),
//     );
//   }

//   Widget registerEmail() {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         border: Border.all(
//           width: 2,
//           color: Colors.deepPurple,
//         ),
//         borderRadius: BorderRadius.circular(26),
//       ),
//       child: Column(
//         children: [
//           Image.asset(
//             "assets/imgs/googleLogo.png",
//             height: 200,
//             width: double.infinity,
//           ),
//           ElevatedButton(
//               onPressed: registerUser, child: Text("Register with Mail")),
//           SizedBox(
//             height: 20,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget signInEmail() {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         border: Border.all(
//           width: 2,
//           color: Colors.deepPurple,
//         ),
//         borderRadius: BorderRadius.circular(26),
//       ),
//       child: Column(
//         children: [
//           Image.asset(
//             "assets/imgs/googleLogo.png",
//             height: 200,
//             width: double.infinity,
//           ),
//           ElevatedButton(
//               onPressed: signIn, child: Text("Sign with Registered Mail")),
//           SizedBox(
//             height: 20,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // const MyHomePage(title: 'Flutter Demo Home Page'),

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/activities/HomePage.dart';
import 'package:scolab/activities/skillsPage.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String loggedin = "";
  bool status = false;
  @override
  void initState() {
    super.initState();
    checkLog();
  }

  void checkLog() async {
    var prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    if (email == null || email.isEmpty) {
      loggedin = "";
    } else {
      print("saved email found: $email");
      if (await MongoDb()
          .checkUserExists(await MongoDb().getConnection(), email)) {
        await prefs.setString('email', "");
        loggedin = "";
      } else {
        loggedin = email;
      }
    }
    setState(() {
      status = true;
    }); // Update the UI after checking the login status
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
      home: status
          ? (loggedin.isEmpty ? signInPage() : HomeScreen())
          : Center(
              child: CircularProgressIndicator(),
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
  late GoogleSignIn _googleSignIn;
  Widget login_space = Container();
  var email = "";

  void connect() async {
    db = await MongoDb().getConnection();
    fetchData();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  void fetchData() async {
    data = await MongoDb().getIds(db);
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
      print(error);
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
      if (data.contains(email) ||
          !await MongoDb()
              .checkUserExists(await MongoDb().getConnection(), email)) {
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
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
      print("error : ***${error}***");
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
  }

  @override
  void initState() {
    login_space = signInEmail();
    connect();
    super.initState();
  }

  var sharedPref = "";

  void lode() async {
    var pref = await SharedPreferences.getInstance();
    sharedPref = pref.getString("email")!;
  }

  @override
  Widget build(BuildContext context) {
    lode();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("SCOLAB"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("<<<<<<${sharedPref}>>>>>>"),
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