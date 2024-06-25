import 'package:flutter/material.dart';
import 'package:scolab/HomePageScreens/requestsPage.dart';
import 'package:scolab/SearchPages/SearchResultPage.dart';
import 'package:scolab/activities/notificationScreen.dart';
import 'package:scolab/activities/skillsPage.dart';
import 'package:scolab/data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    RequestsPage(),
    NotificationScreen(),
    SkillPage(title: "skill info"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() async {
    await getSkill();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 40,
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return dataSkills.where((String option) {
            return option
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          });
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              alignLabelWithHint: true,
              hintText: "Search with your skill",
            ),
          );
        },
        onSelected: (String selection) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SearchResultPage(selection);
            },
          ));
        },
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
          backgroundColor: Color.fromARGB(255, 243, 141, 116),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notification_add),
          label: 'Search',
          backgroundColor: Color.fromARGB(255, 243, 141, 80),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
          backgroundColor: Color.fromARGB(255, 245, 124, 50),
        ),
      ],
      type: BottomNavigationBarType.shifting,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      iconSize: 30,
      onTap: _onItemTapped,
      elevation: 5,
    );
  }
}
