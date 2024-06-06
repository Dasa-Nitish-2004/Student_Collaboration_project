import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:scolab/DatabaseService/databaseServices.dart';

Future<List> get getskills async {
  Db db = await MongoDb().getConnection();
  List skill = [];
  var skills = await db.collection('availskill');
  var k = await skills.find(where.sortBy('skill').fields(['skills'])).toList();
  k.forEach((element) {
    skill = element['skills'];
  });
  // print(skill);
  db.close();
  return skill;
}

Future<Map> getUserData(String email) async {
  Db db = await MongoDb().getConnection();
  var info = await db.collection('user_info');
  var k = await info.find(where.eq("id", email)).toList();
  db.close();
  return k[0];
}

List<String> skills = [
  "python",
  "javaScript",
  "Java",
  "C#",
  "C++",
  "Ruby",
  "Swift",
  "Kotlin",
  "PHP",
  "TypeScript",
  "Go",
  "Rust",
  "SQL",
  "R",
  "MATLAB",
  "HTML",
  "CSS",
  "Sass",
  "Bootstrap",
  "React",
  "Angular",
  "Vue.js",
  "Svelte",
  "jQuery",
  "ASP.NET",
  "Django",
  "Flask",
  "Ruby on Rails",
  "Laravel",
  "Flutter",
  "React Native",
  "Swift (iOS)",
  "Kotlin (Android)",
  "Java (Android)",
  "MySQL",
  "PostgreSQL",
  "SQLite",
  "MongoDB",
  "Redis",
  "Cassandra",
  "Firebase",
  "Oracle DB",
  "Docker",
  "Kubernetes",
  "Jenkins",
  "Git",
  "GitHub",
  "GitLab",
  "CI/CD",
  "AWS",
  "Azure",
  "Google Cloud Platform",
  "Terraform",
  "Ansible",
  "TensorFlow",
  "PyTorch",
  "Scikit-learn",
  "Keras",
  "Pandas",
  "NumPy",
  "Matplotlib",
  "Seaborn",
  "Jupyter",
  "RStudio",
  "Hadoop",
  "Spark",
  "Agile",
  "Scrum",
  "Kanban",
  "TDD",
  "BDD",
  "RESTful APIs",
  "GraphQL",
  "Microservices",
  "OOP",
  "Functional Programming",
  "Version Control",
  "Penetration Testing",
  "Ethical Hacking",
  "Network Security",
  "Cryptography",
  "OWASP",
  "SIEM",
  "Firewalls",
  "IDS",
  "Bash/Shell Scripting",
  "PowerShell",
  "Linux",
  "Unix",
  "Windows Server",
  "macOS",
  "Vagrant",
  "VirtualBox",
  "VMware",
  "Salesforce",
  "SA"
];
