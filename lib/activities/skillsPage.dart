import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _addSkill(); // Initial skill field
    _addProject(); // Initial project field
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

  void _handleSubmit() {
    final userDescription = userDescriptionController.text;
    final gitHub = gitHubController.text;
    final linkedIn = linkedInController.text;
    final skills = skillControllers
        .map((skill) => {
              'skill': skill['skill']!.text,
              'description': skill['description']!.text,
            })
        .toList();
    final projects = projectControllers
        .map((project) => {
              'project': project['project']!.text,
              'description': project['description']!.text,
            })
        .toList();

    print('User Description: $userDescription');
    print('GitHub: $gitHub');
    print('LinkedIn: $linkedIn');
    print('Skills: $skills');
    print('Projects: $projects');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Icon(Icons.article),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_right_alt_rounded),
            onPressed: () {},
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
                  TextField(
                    controller: skill['skill'],
                    maxLines: 1,
                    maxLength: 50,
                    minLines: 1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      hintText: "Skill",
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
                      // suffixIcon: IconButton(
                      //   icon: Icon(Icons.delete, color: Colors.red),
                      //   onPressed: () => _removeSkill(index),
                      // ),
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
                      // suffixIcon: IconButton(
                      //   icon: Icon(Icons.delete, color: Colors.red),
                      //   onPressed: () => _removeProject(index),
                      // ),
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
