import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDoList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    Map<String, dynamic> newToDo = Map();

    if (_toDoController.text.isNotEmpty) {
      newToDo["title"] = _toDoController.text;
      newToDo["ok"] = false;
      _toDoList.add(newToDo);

      setState(() {
        _toDoController.text = "";
        _saveData();
        _refresh();
      });
    }
  }

  Future<Null> _refresh() async {
    List newAFAZER = [];
    List newFEITO = [];
    for (var i = 0; i < _toDoList.length; i++) {
      if (_toDoList[i]["ok"]) {
        newFEITO.add(_toDoList[i]);
      } else {
        newAFAZER.add(_toDoList[i]);
      }
    }

    setState(() {
      newAFAZER.sort(sortListByTitle);
      newFEITO.sort(sortListByTitle);

      _toDoList = [];
      for (var i = 0; i < newAFAZER.length; i++) {
        _toDoList.add(newAFAZER[i]);
      }

      for (var i = 0; i < newFEITO.length; i++) {
        _toDoList.add(newFEITO[i]);
      }
    });

    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "LISTA DE TAREFAS",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: () {
                    _addToDo();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext contexto, int index) {
    return Dismissible(
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error,
              color: Colors.white),
        ),
        onChanged: (c) {
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text(
              "Tarefa \"${_lastRemoved["title"]}\" removida!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            action: SnackBarAction(
                label: "Desfazer",
                textColor: Colors.white,
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.lightBlue,
          );

          Scaffold.of(contexto).removeCurrentSnackBar();
          Scaffold.of(contexto).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  int sortListByTitle(a, b) {
    {
      String a1 = a["title"];
      String b1 = b["title"];

      a1 = a1.toLowerCase();
      b1 = b1.toLowerCase();
      return a1.compareTo(b1);
    }
  }
}
