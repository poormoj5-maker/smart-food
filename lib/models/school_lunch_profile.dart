class SchoolLunchProfile {
  final String childName;
  final int age;
  final String gender;
  final List<String> likes, dislikes, allergies, restrictions;
  final String schoolRules;
  final bool canReheat;
  const SchoolLunchProfile({this.childName='',this.age=8,this.gender='ترجیح می‌دهم نگویم',this.likes=const [],this.dislikes=const [],this.allergies=const [],this.restrictions=const [],this.schoolRules='',this.canReheat=false});
  Map<String,dynamic> toJson()=>{'childName':childName,'age':age,'gender':gender,'likes':likes,'dislikes':dislikes,'allergies':allergies,'restrictions':restrictions,'schoolRules':schoolRules,'canReheat':canReheat};
  factory SchoolLunchProfile.fromJson(Map<String,dynamic> j)=>SchoolLunchProfile(childName:j['childName'] as String? ?? '',age:(j['age'] as num?)?.toInt() ?? 8,gender:j['gender'] as String? ?? 'ترجیح می‌دهم نگویم',likes:_strings(j['likes']),dislikes:_strings(j['dislikes']),allergies:_strings(j['allergies']),restrictions:_strings(j['restrictions']),schoolRules:j['schoolRules'] as String? ?? '',canReheat:j['canReheat'] as bool? ?? false);
  static List<String> _strings(dynamic v)=>v is List ? v.map((e)=>e.toString()).toList() : const [];
}
