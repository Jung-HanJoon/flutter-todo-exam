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

  @override
  void initState() {
    super.initState();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _whatTodo = "";
  String _query = "";
  List<Widget> todoList = [];

  var _tec = TextEditingController();
  var _qtec = TextEditingController();

  void _addToDo() {
    bool checked = false;
    IconData iconData = Icons.star_border;
    Firestore.instance.collection('todo').add({
      'todo': _whatTodo,
      'time': DateFormat.yMMMMd('en_US').format(DateTime.now()).toString(),
      'favorite': false
    });
    // setState(() {
    //   todoList.add(Padding(
    //     padding: const EdgeInsets.fromLTRB(8.0,3.0,8.0,0),
    //     child: ListTile(
    //       tileColor: Colors.white,
    //       title: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Checkbox(value: checked, onChanged: null),
    //           Column(
    //             children: [
    //               Text(_whatTodo),
    //               Text(DateFormat.yMMMMd('en_US').format(DateTime.now()).toString()),
    //             ],
    //           ),
    //           IconButton(
    //             icon: Icon(iconData),
    //             onPressed: () {
    //               setState(() {
    //                 if(iconData==Icons.star_border){
    //                   iconData=Icons.star;
    //                 }else{
    //                   iconData=Icons.star_border;
    //                 }
    //               });
    //             },
    //           ),
    //         ],
    //       ),
    //     ),
    //   ));
    //   todoList.reversed;
    // });
    _tec.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(""),
            Text('Inbox'),
            TextButton(onPressed: () {}, child: Text('Search'))
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
            ),
            Expanded(
              child: ListView(
                children: todoList,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: ListView(
            //     children: todoList,
            //   ),
            // ),
            ElevatedButton(
                onPressed: () {}, child: Text('SHOW COMPLETED TO -DOS')),
            Expanded(
              child: _buildBody(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('todo').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _qtec,
      onChanged: (v) {
        _query = v;
      },
      decoration: InputDecoration(
        labelText: '검색어 입력',
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final todo = ToDo.fromSnapshot(data);

    return Padding(
      key: ValueKey(todo.todo),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(todo.todo),
          trailing: Text(todo.time.toString()),
          tileColor: Colors.white,
          // onTap: () => todo.reference. ({'time': DateFormat.yMMMMd('en_US').format(DateTime.now()).toString()}),
        ),
      ),
    );
  }
}
