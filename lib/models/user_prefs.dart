class UserPrefs {
  final String city, level; final bool showLocalFirst, loggedIn, welcomed;
  final List<String> pantry, favorites;
  const UserPrefs({this.city='تهران',this.level='روزمره',this.showLocalFirst=true,this.loggedIn=false,this.welcomed=false,this.pantry=const [],this.favorites=const []});
  UserPrefs copyWith({String? city,String? level,bool? showLocalFirst,bool? loggedIn,bool? welcomed,List<String>? pantry,List<String>? favorites})=>UserPrefs(city:city??this.city,level:level??this.level,showLocalFirst:showLocalFirst??this.showLocalFirst,loggedIn:loggedIn??this.loggedIn,welcomed:welcomed??this.welcomed,pantry:pantry??this.pantry,favorites:favorites??this.favorites);
}
