import 'package:flutter/material.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';
import 'package:scolab/data.dart' as data;
import 'package:scolab/request_bluePrint.dart';
import 'package:intl/intl.dart';

class AddRequestPage extends StatefulWidget {
  final void Function({Request? k}) addRequest;
  final Request? k;
  AddRequestPage(this.addRequest, {this.k, Key? key}) : super(key: key);

  @override
  State<AddRequestPage> createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  final List<Map<String, TextEditingController>> skillControllers = [];
  List<String> skillSuggestions = [];
  final TextEditingController projectTitle = TextEditingController();
  final TextEditingController projectDescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSkills();
    if (widget.k != null) {
      _fetchUserData();
    }
  }

  // Fetch user data if Request object is passed
  void _fetchUserData() async {
    _showLoadingDialog();
    try {
      // Uncomment and modify as necessary if userRequest fetching logic is needed
      // var userRequest = await data.getRequest(email, widget.k!.projectTitle);
      setState(() {
        _populateUserData();
      });
      Navigator.pop(context); // Close loading dialog
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog("Error fetching user data: $error");
    }
  }

  // Populate user data in the form fields
  void _populateUserData() {
    projectTitle.text = widget.k!.projectTitle;
    projectDescription.text = widget.k!.projectDesc;
    for (var skill in widget.k!.skills) {
      _addSkill(skill);
    }
  }

  // Show a loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  // Show an error dialog
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

  // Initialize skills by fetching from data source
  void _initializeSkills() async {
    _showLoadingDialog();
    try {
      await data.getSkill();
      var skills = data.dataSkills;
      Navigator.pop(context);
      setState(() {
        skillSuggestions.addAll(skills.map((e) => e.toLowerCase()));
      });
    } catch (error) {
      Navigator.pop(context);
      _showErrorDialog("Failed to load skills. Please try again.");
    }
  }

  // Remove a skill entry
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

  // Add a skill entry
  void _addSkill(Map skill) {
    setState(() {
      skillControllers.add({
        'skill': TextEditingController(text: skill['skill']),
        'description': TextEditingController(text: skill['description']),
      });
    });
  }

  // Build the skill entry widget
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
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: 24),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        skill['skill']!.text = textEditingController.text;
                        skillSuggestions.add(textEditingController.text);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Skill added successfully"),
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

  // Get skills from the controllers
  List<Map<String, String>> _getSkills() {
    return skillControllers.map((skill) {
      return {
        'skill': skill['skill']!.text,
        'description': skill['description']!.text,
      };
    }).toList();
  }

  // Validate user input
  bool _isInputValid(
      String prjTitle, String prjDesc, List<Map<String, String>> skills) {
    final allSkills = skills.map((e) => e['skill']!).toList();
    final uniqueSkills = allSkills.toSet().toList();
    return prjTitle.isNotEmpty &&
        prjDesc.isNotEmpty &&
        allSkills.length == uniqueSkills.length;
  }

  // Submit user data to the database
  Future<void> _submitData(
    String prjTitle,
    String prjDesc,
    List<Map<String, String>> skills,
  ) async {
    _showLoadingDialog();
    try {
      var email = data.hostemail;

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

        if (widget.k == null) {
          await MongoDb().addRequest(
              db,
              request,
              Request(
                  projectTitle: "",
                  projectDesc: "",
                  Hostname: "",
                  Participants: [],
                  date: "",
                  skills: []),
              false);
          widget.addRequest(k: request);
        } else {
          await MongoDb().addRequest(db, request, widget.k!, true);
          data.req.remove(widget.k);
          widget.addRequest(k: request);
        }

        await MongoDb().updateSkill(db, skillSuggestions);
        data.dataSkills = skillSuggestions;
        db.close();
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Close request Edit
      } else {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog("No email found in SharedPreferences.");
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog("Error submitting data. Please try again.");
    }
  }

  // Handle submit button click
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 50),
          child: Column(
            children: [
              SizedBox(height: 20),
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
                      color: Theme.of(context).colorScheme.inversePrimary,
                      size: 24),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: projectDescription,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  hintText: "Project Description",
                  helperText: "Enter Project Explanation",
                  prefixIcon: Icon(Icons.article,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      size: 24),
                ),
              ),
              SizedBox(height: 20),
              ...skillControllers.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, TextEditingController> skill = entry.value;
                return _buildSkillEntry(index, skill);
              }).toList(),
              ElevatedButton(
                onPressed: () => _addSkill({'skill': '', 'description': ''}),
                child: Text("Add Skill Request"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
