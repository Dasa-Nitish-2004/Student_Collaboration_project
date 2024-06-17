import 'package:flutter/material.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/activities/HomePage.dart';
import 'package:scolab/data.dart' as data;
import 'package:scolab/request_bluePrint.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AddRequestPage extends StatefulWidget {
  void Function(Request k) addRequest;
  AddRequestPage(void Function(Request k) this.addRequest, {super.key});
  @override
  State<AddRequestPage> createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  final List<Map<String, TextEditingController>> skillControllers = [];
  final List<String> skillSuggestions = [];
  final TextEditingController projectTitle = TextEditingController();
  final TextEditingController projectDescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSkills();
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

  void _initializeSkills() async {
    _showLoadingDialog();
    try {
      var skills = await data.getskills;
      Navigator.pop(context);
      setState(() {
        skillSuggestions.addAll(skills.map((e) => e.toLowerCase()));
      });
    } catch (error) {
      Navigator.pop(context);
      _showErrorDialog("Failed to load skills. Please try again.");
    }
  }

  void _removeSkill(int index) {
    setState(() {
      skillControllers[index]['skill']!.dispose();
      skillControllers[index]['description']!.dispose();
      skillControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    projectDescription.dispose();
    projectTitle.dispose();
    for (var skill in skillControllers) {
      skill['skill']!.dispose();
      skill['description']!.dispose();
    }
    super.dispose();
  }

  void _addSkill(Map skill) {
    setState(() {
      skillControllers.add({
        'skill': TextEditingController(text: skill['skill']),
        'description': TextEditingController(text: skill['description']),
      });
    });
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
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Added to ensure Row takes minimum width
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        skill['skill']!.text = textEditingController.text;
                        skillSuggestions.add(textEditingController.text);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("skill added successfully"),
                          duration: Duration(seconds: 1),
                        ));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSkill(index),
                    ),
                  ],
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

  List<Map<String, String>> _getSkills() {
    return skillControllers.map((skill) {
      return {
        'skill': skill['skill']!.text,
        'description': skill['description']!.text,
      };
    }).toList();
  }

  bool _isInputValid(
      String prjTitle, String prjDesc, List<Map<String, String>> skills) {
    final allSkills = skills.map((e) => e['skill']!).toList();
    final uniqueSkills = allSkills.toSet().toList();
    return prjTitle.isNotEmpty &&
        prjDesc.isNotEmpty &&
        allSkills.length == uniqueSkills.length;
  }

  Future<void> _submitData(
    String prjTitle,
    String prjDesc,
    List<Map<String, String>> skills,
  ) async {
    _showLoadingDialog();
    try {
      var prefs = await SharedPreferences.getInstance();
      var email = prefs.getString("email");

      if (email != null) {
        var db = await MongoDb().getConnection();
        Request request = Request(
          projectTitle: prjTitle,
          projectDesc: prjDesc,
          Hostname: email,
          Participants: [],
          date: DateFormat.yMd().add_jm().format(DateTime.now()),
          skills: skills,
        );

        await MongoDb().addRequest(db, request);
        widget.addRequest(request);
        var skillSet = skillSuggestions.toSet().toList();
        await MongoDb().updateSkill(db, skillSet);

        db.close();
        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog("No email found in SharedPreferences.");
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog("Error submitting data. Please try again.");
    }
  }

  void _handleSubmit() async {
    final prjTitle = projectTitle.text;
    final prjDesc = projectDescription.text;
    final skills = _getSkills();

    if (_isInputValid(prjTitle, prjDesc, skills)) {
      await _submitData(prjTitle, prjDesc, skills);
    } else {
      _showErrorDialog(
          "Please enter every detail! Check for duplicate skills and projects.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Request'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 50),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: projectTitle,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  hintText: "Project Title",
                  helperText: "Enter Project Title",
                  prefixIcon: Icon(Icons.assignment,
                      color: Colors.deepPurple, size: 24),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: projectDescription,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  hintText: "Project Description",
                  helperText: "Enter Project Explaination",
                  prefixIcon:
                      Icon(Icons.article, color: Colors.deepPurple, size: 24),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ...skillControllers.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, TextEditingController> skill = entry.value;
                return _buildSkillEntry(index, skill);
              }).toList(),
              ElevatedButton(
                onPressed: () => _addSkill({'skill': '', 'description': ''}),
                child: Text("Add Skill Request"),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: _handleSubmit, child: Text("Submit"))
            ],
          ),
        ),
      ),
    );
  }
}
