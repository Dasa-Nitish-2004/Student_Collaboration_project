class Request {
  final String projectTitle;
  final String projectDesc;
  final String Hostname;
  final List<String> Participants;
  final String date;
  final List<Map<String, String>> skills;

  Request({
    required this.projectTitle,
    required this.projectDesc,
    required this.Hostname,
    required this.Participants,
    required this.date,
    required this.skills,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectTitle': projectTitle,
      'projectDesc': projectDesc,
      'Hostname': Hostname,
      'Participants': Participants,
      'date': date,
      'skills': skills,
    };
  }
}
