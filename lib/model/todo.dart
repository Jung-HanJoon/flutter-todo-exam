import 'package:cloud_firestore/cloud_firestore.dart';

class ToDo{
  String todo;
  bool favorite=false;
  String time;
  final DocumentReference reference;

  ToDo.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['todo'] != null),
        assert(map['favorite'] != null),
        assert(map['time'] != null),
        todo = map['todo'],
        favorite = map['favorite'],
        time = map['time'];

  ToDo.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);



  @override
  String toString() => "ToDo<$time:$todo>";
}
