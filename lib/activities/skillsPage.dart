import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/activities/HomePage.dart';
import 'package:scolab/data.dart' as data;
import 'package:shared_preferences/shared_preferences.dart';

class SkillPage extends StatefulWidget {
  const SkillPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SkillPage> createState() => _SkillPageState();
}

class _SkillPageState extends State<SkillPage> {
  var userInfo = {};
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
    _initializeSkills();
    _fetchUserData();
  }

  void _initializeSkills() async {
    try {
      var skills = await data.getskills;
      setState(() {
        skillSuggestions.addAll(skills.map((e) => e.toLowerCase()));
      });
    } catch (error) {
      _showErrorDialog("Failed to load skills. Please try again.");
    }
  }

  void _fetchUserData() async {
    _showLoadingDialog();
    var prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");

    if (email == null) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog("No email found in SharedPreferences.");
      return;
    }

    try {
      String? userDescription = prefs.getString("user_description");
      String? gitHub = prefs.getString("github");
      String? linkedIn = prefs.getString("linkedin");
      String? skillsString = prefs.getString("skills");
      String? projectsString = prefs.getString("projects");

      List<Map<String, String>> skills = skillsString != null
          ? (List<Map<String, String>>.from(json
              .decode(skillsString)
              .map((item) => Map<String, String>.from(item))))
          : [];
      List<Map<String, String>> projects = projectsString != null
          ? (List<Map<String, String>>.from(json
              .decode(projectsString)
              .map((item) => Map<String, String>.from(item))))
          : [];

      setState(() {
        userInfo = {
          'email': email,
          'user_description': userDescription ?? '',
          'github': gitHub ?? '',
          'linkedin': linkedIn ?? '',
          'skills': skills,
          'projects': projects,
        };
        _populateUserData(userInfo);
      });
      Navigator.pop(context); // Close loading dialog
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog("Error fetching user data: $error");
    }
  }

  void _populateUserData(Map userData) {
    userDescriptionController.text = userData['user_description'] ?? '';
    gitHubController.text = userData['github'] ?? '';
    linkedInController.text = userData['linkedin'] ?? '';

    for (var skill in userData['skills'] ?? []) {
      _addSkill(skill);
    }
    for (var project in userData['projects'] ?? []) {
      _addProject(project);
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

  void _addSkill(Map<String, String> skill) {
    setState(() {
      skillControllers.add({
        'skill': TextEditingController(text: skill['skill']),
        'description': TextEditingController(text: skill['description']),
      });
    });
  }

  void _addProject(Map<String, String> project) {
    setState(() {
      projectControllers.add({
        'project': TextEditingController(text: project['project']),
        'description': TextEditingController(text: project['description']),
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
    final skills = _getSkills();
    final projects = _getProjects();

    if (_isInputValid(userDescription, gitHub, linkedIn, skills, projects)) {
      await _submitData(userDescription, gitHub, linkedIn, skills, projects);
    } else {
      _showErrorDialog(
          "Please enter every detail! Check for duplicate skills and projects.");
    }
  }

  List<Map<String, String>> _getSkills() {
    return skillControllers.map((skill) {
      return {
        'skill': skill['skill']!.text,
        'description': skill['description']!.text,
      };
    }).toList();
  }

  List<Map<String, String>> _getProjects() {
    return projectControllers.map((project) {
      return {
        'project': project['project']!.text,
        'description': project['description']!.text,
      };
    }).toList();
  }

  bool _isInputValid(String userDescription, String gitHub, String linkedIn,
      List<Map<String, String>> skills, List<Map<String, String>> projects) {
    final allSkills = skills.map((e) => e['skill']!).toList();
    final allProjects = projects.map((e) => e['project']!).toList();
    final uniqueSkills = allSkills.toSet().toList();
    final uniqueProjects = allProjects.toSet().toList();

    return userDescription.isNotEmpty &&
        gitHub.isNotEmpty &&
        linkedIn.isNotEmpty &&
        allSkills.length == uniqueSkills.length &&
        allProjects.length == uniqueProjects.length;
  }

  Future<void> _submitData(
      String userDescription,
      String gitHub,
      String linkedIn,
      List<Map<String, String>> skills,
      List<Map<String, String>> projects) async {
    _showLoadingDialog();
    try {
      var prefs = await SharedPreferences.getInstance();
      var email = prefs.getString("email");

      if (email != null) {
        var db = await MongoDb().getConnection();
        await MongoDb().modifyUser(db, email,
            github: gitHub,
            linkedin: linkedIn,
            user_desc: userDescription,
            skills: skills,
            projects: projects);
        db.close();

        // Update SharedPreferences
        await prefs.setString("user_description", userDescription);
        await prefs.setString("github", gitHub);
        await prefs.setString("linkedin", linkedIn);
        await prefs.setString("skills", json.encode(skills));
        await prefs.setString("projects", json.encode(projects));

        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog("No email found in SharedPreferences.");
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog("Error submitting data. Please try again.");
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            _buildSectionHeader("Profile"),
            SizedBox(height: 10),
            _buildTextField(userDescriptionController, "Description",
                "User Description", Icons.person),
            SizedBox(height: 10),
            _buildTextField(
                gitHubController, "GitHub", "GitHub Profile URL", Icons.link),
            SizedBox(height: 10),
            _buildTextField(linkedInController, "LinkedIn",
                "LinkedIn Profile URL", Icons.link),
            SizedBox(height: 20),
            _buildSectionHeader("Skills"),
            SizedBox(height: 10),
            ...skillControllers.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, TextEditingController> skill = entry.value;
              return _buildSkillEntry(index, skill);
            }).toList(),
            ElevatedButton(
              onPressed: () => _addSkill({'skill': '', 'description': ''}),
              child: Text("Add Skill"),
            ),
            SizedBox(height: 20),
            _buildSectionHeader("Projects"),
            SizedBox(height: 10),
            ...projectControllers.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, TextEditingController> project = entry.value;
              return _buildProjectEntry(index, project);
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

  Widget _buildTextField(TextEditingController controller, String hintText,
      String helperText, IconData icon) {
    return TextField(
      controller: controller,
      maxLines: 1,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        hintText: hintText,
        helperText: helperText,
        prefixIcon: Icon(icon, color: Colors.deepPurple, size: 24),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      "$title...",
      textAlign: TextAlign.left,
      style: TextStyle(
        color: Colors.deepPurple,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSkillEntry(int index, Map<String, TextEditingController> skill) {
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
                prefixIcon: Icon(Icons.text_snippet_rounded,
                    color: Colors.deepPurple, size: 24),
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
  }

  Widget _buildProjectEntry(
      int index, Map<String, TextEditingController> project) {
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
            prefixIcon: Icon(Icons.work, color: Colors.deepPurple, size: 24),
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
  }
}
