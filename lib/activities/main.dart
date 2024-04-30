import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scolab/activities/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: AnimatedSplashScreen(
          splash: 'assets/imgs/appIcon.png',
          duration: 3000,
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.white,
          // nextScreen: MyHomePage(title: 'Flutter Demo Home Page'),
          nextScreen: signInPage(),
          // pageTransitionType: PageTransitionType.scale,
        ));
  }
}

class signInPage extends StatefulWidget {
  @override
  State<signInPage> createState() => _signInPageState();
}

class _signInPageState extends State<signInPage> {
  late GoogleSignIn _googleSignIn;

  Widget login_space = Container();
  var email = "";

  signIn() async {
    print("signin");
    _googleSignIn = GoogleSignIn();
    try {
      var result = await _googleSignIn.signIn();
      email = result!.email;
      print("successfull -- > $result");
    } catch (error) {
      print(error);
    } finally {
      setState(() {});
    }
  }

  signOut() => _googleSignIn.disconnect();
  @override
  void initState() {
    // TODO: implement initState
    login_space = signInEmail();
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