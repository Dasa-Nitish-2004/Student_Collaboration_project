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
  final TextEditingController userDescriptionController =
      TextEditingController();
  final TextEditingController gitHubController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final List<Map<String, TextEditingController>> skillControllers = [];
  final List<Map<String, TextEditingController>> projectControllers = [];

  // final List<String> skillSuggestions = data.skills;
  final List<String> skillSuggestions = [];
  // final List<String> actualSkills = [];

  @override
  void initState() {
    super.initState();
    // _addSkill(); // Initial skill field
    // _addProject(); // Initial project field
    getSkills();
  }

  void getSkills() async {
    var skills = await data.getskills;
    skills.forEach((element) {
      skillSuggestions.add(element.toLowerCase());
    });
    // actualSkills.addAll(skillSuggestions);
    print("********$skillSuggestions#####################");
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

  void _addSkill() {
    setState(() {
      skillControllers.add({
        'skill': TextEditingController(),
        'description': TextEditingController(),
      });
    });
  }

  void _addProject() {
    setState(() {
      projectControllers.add({
        'project': TextEditingController(),
        'description': TextEditingController(),
      });
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
      // data.skills.add(skill['skill']!.text);
      // DataFile().addSkill();
      // DataFile().addSkill(skill['skill']!.text);

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
      } else {
        // return null;
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
      } else {
        // return null;
      }
    }).toList();
    projects.removeNull();
    if (userDescription.isEmpty || gitHub.isEmpty || linkedIn.isEmpty) {
      isentryValid = false;
    }

    String content = isentryValid
        ? 'User Description: $userDescription\nGitHub: $gitHub\nLinkedIn: $linkedIn\nSkills: $skills\nProjects: $projects\n'
        : "Please enter every details!\ncheck no duplicate skills and projects";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isentryValid ? "Check Entry Details" : 'Invalid input'),
        content: Container(
            height: 300, child: SingleChildScrollView(child: Text(content))),
        actions: [
          TextButton(
            onPressed: () async {
              if (isentryValid) {
                var db;
                try {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
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
                  // db.close();
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
                        Text("ERROR! Check internet connectivity. try again"),
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
    var db;
    try {
      db = await MongoDb().getConnection();
      var data = await MongoDb().getIds(db);
      print(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Check internet connectivity"),
        duration: Duration(seconds: 3),
      ));
    } finally {}
    db.close();
    return;
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
            icon: Icon(
              Icons.arrow_right_alt_rounded,
            ),
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
                helperText: "basic info that you want to show",
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.deepPurple,
                  size: 24,
                ),
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
                prefixIcon: Image.asset(
                  "assets/imgs/github3D.png",
                  height: 24,
                ),
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
                prefixIcon: Image.asset(
                  "assets/imgs/linkedin.png",
                  height: 24,
                ),
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
                      return TextField(
                        onChanged: (value) {
                          // skillSuggestions.add(textEditingController.text);
                          skill['skill']!.text = value;
                        },
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          hintText: "Skill",
                          helperText: "click plus for new skill",
                          prefixIcon: Icon(
                            Icons.person,
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
              onPressed: _addSkill,
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
                      prefixIcon: Icon(
                        Icons.work,
                        color: Colors.deepPurple,
                        size: 24,
                      ),
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
              onPressed: _addProject,
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
