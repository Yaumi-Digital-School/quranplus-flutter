// ignore_for_file: file_names, unnecessary_this, prefer_collection_literals

class Bookmarks{
  int? id;
  String? suratid;
  String? ayatid;

  Bookmarks({
    this.id, 
    this.suratid, 
    this.ayatid
  });

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = id;
    }
    map['suratid'] = suratid; 
    map['ayatid'] = ayatid;
    
    return map;
  }

  Bookmarks.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.suratid = map['suratid'];
    this.ayatid = map['ayatid'];
  }
}