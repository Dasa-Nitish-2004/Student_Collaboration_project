import 'package:flutter/material.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/activities/HomePage.dart';
import 'package:scolab/data.dart' as data;
import 'package:list_utilities/list_utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SkillPage extends StatefulWidget {
  const SkillPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SkillPage> createState() => _SkillPageState();
}

class _SkillPageState extends State<SkillPage> {
  var user_info = {};
  final TextEditingController userDescriptionController =
      TextEditingController();
  final TextEditingController gitHubController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final List<Map<String, TextEditingController>> skillControllers = [];
  final List<Map<String, TextEditingController>> projectControllers = [];
  final List<String> skillSuggestions = [];

  @override
  void initState() {
    super.initState();
    getSkills();
  }

  void getSkills() async {
    var skills = await data
        .getskills; // Assuming data.getskills returns a Future<List<String>>
    setState(() {
      skills.forEach((element) {
        skillSuggestions.add(element.toLowerCase());
      });
    });
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    var pref = await SharedPreferences.getInstance();
    String? email = pref.getString("email");

    if (email != null) {
      Future<Map> userDataFuture = data.getUserData(email);

      // Use the fetched user data
      userDataFuture.then((userData) {
        setState(() {
          user_info["skills"] = userData['skill'];
          user_info["projects"] = userData['projects'];
          user_info["github"] = userData['github'];
          user_info["linkedin"] = userData['linkedin'];
          user_info["user_desc"] = userData['user_description'];

          userDescriptionController.text = user_info["user_desc"];
          gitHubController.text = user_info["github"];
          linkedInController.text = user_info["linkedin"];

          for (var skill in user_info['skills']) {
            _addSkill(skill);
          }
          for (var project in user_info['projects']) {
            _addProject(project);
          }
        });
        Navigator.pop(context);
      }).catchError((error) {
        print('Error fetching user data: $error');
      });
    } else {
      print('No email found in SharedPreferences');
    }
  }

  @override
  void dispose() {
    userDescriptionController.dispose();
    gitHubController.dispose();
    linkedInController.dispose();
    for (var skill in skillControllers) {
      skill['skill']!.dispose();
      skill['description']!.dispose();
    }
    for (var project in projectControllers) {
      project['project']!.dispose();
      project['description']!.dispose();
    }
    super.dispose();
  }

  void _addSkill(Map skill) {
    setState(() {
      var skillController = {
        'skill': TextEditingController(text: skill['skill']),
        'description': TextEditingController(text: skill['description']),
      };
      skillControllers.add(skillController);
    });
  }

  void _addProject(Map project) {
    setState(() {
      var projectController = {
        'project': TextEditingController(text: project['project']),
        'description': TextEditingController(text: project['description']),
      };
      projectControllers.add(projectController);
    });
  }

  void _removeSkill(int index) {
    setState(() {
      skillControllers[index]['skill']!.dispose();
      skillControllers[index]['description']!.dispose();
      skillControllers.removeAt(index);
    });
  }

  void _removeProject(int index) {
    setState(() {
      projectControllers[index]['project']!.dispose();
      projectControllers[index]['description']!.dispose();
      projectControllers.removeAt(index);
    });
  }

  void _handleSubmit() async {
    final userDescription = userDescriptionController.text;
    final gitHub = gitHubController.text;
    final linkedIn = linkedInController.text;
    bool isentryValid = true;
    List dup_skills = [];
    List dup_projects = [];

    final skills = skillControllers.map((skill) {
      if (skill['skill']!.text.trim().isNotEmpty) {
        if (!dup_skills.contains(skill['skill']!.text)) {
          dup_skills.add(skill['skill']!.text);
          return {
            'skill': skill['skill']!.text,
            'description': skill['description']!.text,
          };
        } else {
          isentryValid = false;
        }
      }
    }).toList();
    skills.removeNull();

    final projects = projectControllers.map((project) {
      if (project['project']!.text.trim().isNotEmpty) {
        if (!dup_projects.contains(project['project']!.text)) {
          dup_projects.add(project['project']!.text);
          return {
            'project': project['project']!.text,
            'description': project['description']!.text,
          };
        } else {
          isentryValid = false;
        }
      }
    }).toList();
    projects.removeNull();

    if (userDescription.isEmpty || gitHub.isEmpty || linkedIn.isEmpty) {
      isentryValid = false;
    }

    String content = isentryValid
        ? 'User Description: $userDescription\nGitHub: $gitHub\nLinkedIn: $linkedIn\nSkills: $skills\nProjects: $projects\n'
        : "Please enter every detail! Check for duplicate skills and projects.";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isentryValid ? "Check Entry Details" : 'Invalid input'),
        content: Container(
          height: 300,
          child: SingleChildScrollView(child: Text(content)),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (isentryValid) {
                var db;
                try {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Center(child: CircularProgressIndicator());
                    },
                  );
                  var prefs = await SharedPreferences.getInstance();
                  var email = prefs.getString("email");
                  db = await MongoDb().getConnection();
                  MongoDb().modifyUser(db, email!,
                      github: gitHub,
                      linkedin: linkedIn,
                      user_desc: userDescription,
                      skills: skills,
                      projects: projects);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return HomeScreen();
                    },
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text("ERROR! Check internet connectivity. Try again."),
                    duration: Duration(seconds: 3),
                  ));
                } finally {
                  db.close();
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: Icon(Icons.article),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_right_alt_rounded),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: userDescriptionController,
              maxLines: 10,
              maxLength: 500,
              minLines: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                hintText: "User Description",
                helperText: "Basic info that you want to show",
                prefixIcon:
                    Icon(Icons.person, color: Colors.deepPurple, size: 24),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: gitHubController,
              maxLength: 50,
              minLines: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                hintText: "GitHub",
                prefixIcon: Image.asset("assets/imgs/github3D.png", height: 24),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: linkedInController,
              maxLines: 1,
              maxLength: 50,
              minLines: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                hintText: "LinkedIn",
                prefixIcon: Image.asset("assets/imgs/linkedin.png", height: 24),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Skills...",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...skillControllers.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, TextEditingController> skill = entry.value;
              return Column(
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return skillSuggestions.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      textEditingController.text = skill['skill']!.text;
                      return TextField(
                        onChanged: (value) {
                          skill['skill']!.text = value;
                        },
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          hintText: "Skill",
                          helperText: "Click plus for new skill",
                          prefixIcon: Icon(
                            Icons.text_snippet_rounded,
                            color: Colors.deepPurple,
                            size: 24,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSkill(index),
                          ),
                        ),
                      );
                    },
                    onSelected: (String selection) {
                      skill['skill']!.text = selection;
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: skill['description'],
                    maxLines: 5,
                    maxLength: 500,
                    minLines: 1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      hintText: "Skill Description",
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
            ElevatedButton(
              onPressed: () => _addSkill({'skill': '', 'description': ''}),
              child: Text("Add Skill"),
            ),
            SizedBox(height: 20),
            Text(
              "Projects...",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...projectControllers.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, TextEditingController> project = entry.value;
              return Column(
                children: [
                  TextField(
                    controller: project['project'],
                    maxLines: 1,
                    maxLength: 50,
                    minLines: 1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      hintText: "Project",
                      prefixIcon:
                          Icon(Icons.work, color: Colors.deepPurple, size: 24),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeProject(index),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: project['description'],
                    maxLines: 5,
                    maxLength: 500,
                    minLines: 1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      hintText: "Project Description",
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
            ElevatedButton(
              onPressed: () => _addProject({'project': '', 'description': ''}),
              child: Text("Add Project"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
