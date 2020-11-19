import 'package:flutter/material.dart';
import 'package:flutter_todo_exam/model/todo.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: Colors.lightGreen,
          accentColor: Colors.black),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _whatTodo = ""; //입력받은 할일 내용
  String _query = ""; //검색을 위한 쿼리 미구현으로 미사용
  List<ToDo> todoList=[];
  var _tec = TextEditingController();
  var _tec2 = TextEditingController();
  var _qtec = TextEditingController();


  void _addToDo() {
    //DB에 할일 저장하는 함수
    Firestore.instance.collection('todo').add({
      'todo': _whatTodo, //할일 텍스트
      'time': DateFormat.yMMMMd('en_US')
          .add_jm()
          .format(DateTime.now())
          .toString(), //현재 시간
      'favorite': false //할일 완료 여부 표시
    });
    _tec.text = ''; //할일 추가 시 텍스트 필드 비움
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Inbox'),
            Expanded(
                child: TextField(decoration: InputDecoration(labelText: '검색'), controller: _qtec, onChanged: (text) {
                  setState(() {
                    _query = text;
                  });
                },)),
            TextButton(onPressed: () {}, child: Text('Search'))
          ],
        ),
      ),
      body: Container(
        color: Colors.lightGreen,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(icon: Icon(Icons.add), onPressed: _addToDo),
                    Expanded(
                      child: TextField(
                        controller: _tec,
                        onChanged: (v) {
                            _whatTodo = v;
                        },
                        decoration: InputDecoration(
                          labelText: 'Add a to-do...',
                        ),
                      ),
                    ),
                    IconButton(icon: Icon(Icons.star_border), onPressed: () {})
                  ],
                ),
              ),
            ), //할 일 입력하는 공간
            Text(
              '작업 목록',
              style: TextStyle(fontSize: 30),
            ), //작업 목록 구분용 텍스트
            Expanded(
              child: _buildBody(context, false),
            ), //작업 리스트
            Text(
              '완료한 작업',
              style: TextStyle(fontSize: 30),
            ), //완료한 작업 목록 구분용 텍스트
            Expanded(
              child: _buildBody(context, true),
            ) //작업 리스트
          ],
        ),
      ),
    );
  }


  //DB에서 값을 가져와서 넘겨주기까지
  Widget _buildBody(BuildContext context, bool done) {
    return StreamBuilder<QuerySnapshot>(
      //스트림빌더를 활용해서 Setstate를 사용하지 않았음.
      stream: Firestore.instance
          .collection('todo')
          .where("favorite", isEqualTo: done)
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return CircularProgressIndicator();
        todoList = snapshot.data.documents.map((e) => ToDo.fromSnapshot(e)).toList();//스냅샷이 비워져있을시 미구현
        return _buildList(context, todoList);
      },
    );
  }

  //넘겨준 객체(스냅샷)마다 map으로 돌려서 ListTile 만드는 함수를 부르고, 결과값을 ListView에 뿌려주기
  Widget _buildList(BuildContext context, List<ToDo> todoList) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lime,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ListView(
        padding: const EdgeInsets.only(top: 20.0),
        children:
        todoList.where((e) => e.todo.toLowerCase().contains(_query.toLowerCase())).map((data) => _buildListItem(context, data)).toList(),
      ),
    );
  }

  //검색 쿼리를 활용하기 위한 함수. 미구현
  Widget _buildSearch() {
    return TextField(
      controller: _tec2,
      onChanged: (v) {
        _query = v;
      },
      decoration: InputDecoration(
        labelText: '검색어 입력',
      ),
    );
  }

  //ListTile에 값을 뿌려주기
  Widget _buildListItem(BuildContext context, ToDo data) {
    final todo = data;
    IconData iconData = todo.favorite
        ? Icons.star
        : Icons.star_border; //작업 완료 여부를 표시하기 위해 참조할 아이콘 데이터
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(todo.todo, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  todo.time.toString(),
                  style: TextStyle(color: Colors.blue),
                )
              ],
            ),
            trailing: IconButton(
              icon: Icon(iconData),
              onPressed: () {
                todo.reference.updateData({
                  'favorite': !(todo.favorite),
                  'time': DateFormat.yMMMMd('en_US')
                      .add_jm()
                      .format(DateTime.now())
                      .toString()
                });
              },
            ),
            tileColor: Colors.white,
            onTap: () {
              var dialtec = TextEditingController();
              dialtec.text = todo.todo;
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("작업 내용 수정"),
                      content: TextField(
                        controller: dialtec,
                      ),
                      actions: [
                        MaterialButton(
                            child: Text("수정"),
                            onPressed: () {
                              todo.reference.updateData({
                                'todo': dialtec.text,
                                'time': DateFormat.yMMMMd('en_US')
                                    .add_jm()
                                    .format(DateTime.now())
                                    .toString()
                              });
                              Navigator.pop(context);
                            }),
                      ],
                    );
                  });
            },
            onLongPress: () {
              final snackBar = SnackBar(
                content: Text('이 작업을 삭제하시겠습니까?'),
                action: SnackBarAction(
                  label: '삭제',
                  onPressed: () {
                    todo.reference.delete();
                  },
                ),
              );
              Scaffold.of(context).showSnackBar(snackBar);
            }),
      ),
    );
  }
}
