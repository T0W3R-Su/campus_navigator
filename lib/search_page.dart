import 'package:flutter/material.dart';
import 'floor_plan_view.dart'; // 平面图视图
import 'models/classroom.dart'; // 教室模型
import 'services/classroom_service.dart'; // 教室服务

// 选择当前教室的搜索页面
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController(); // 用于搜索输入
  List<Classroom> _filteredClassrooms = []; // 用于存储搜索结果
  final ClassroomService _classroomService = ClassroomService(); // 用于搜索教室

  /*
  * 当用户输入文本时，将调用此方法。
  * 搜索输入的文本并更新 _filteredClassrooms。
  */
  void _onSearchTextChanged(String text) async {
    if (text.isEmpty) {
      setState(() {
        _filteredClassrooms = [];
      });
      return;
    }

    List<Classroom> classrooms =
        await _classroomService.getClassroomsByPrefix(text);

    setState(() {
      _filteredClassrooms = classrooms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('教学楼导航'),
      ),
      body: Column(
        children: <Widget>[
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchTextChanged,
              decoration: const InputDecoration(
                labelText: '请输入当前教室',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // 显示搜索结果
          Expanded(
            child: _filteredClassrooms.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredClassrooms.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredClassrooms[index].name),
                        onTap: () {
                          // 跳转到平面图视图
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FloorPlanView(
                                  classroom: _filteredClassrooms[index]),
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(child: Text('无匹配教室')),
          ),
          Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20.0),
              child: const Text(
                'By Su Runxun',
                style: TextStyle(color: Colors.black45),
              )),
        ],
      ),
    );
  }
}

// 选择目标教室的搜索页面
class TargetSearchPage extends StatefulWidget {
  const TargetSearchPage({super.key});

  @override
  _TargetSearchPage createState() => _TargetSearchPage();
}

class _TargetSearchPage extends State<TargetSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Classroom> _filteredClassrooms = [];
  final ClassroomService _classroomService = ClassroomService();

  /*
  * 当用户输入文本时，将调用此方法。
  * 搜索输入的文本并更新 _filteredClassrooms。
  */
  void _onSearchTextChanged(String text) async {
    if (text.isEmpty) {
      setState(() {
        _filteredClassrooms = [];
      });
      return;
    }

    List<Classroom> classrooms =
        await _classroomService.getClassroomsByPrefix(text);

    setState(() {
      _filteredClassrooms = classrooms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目标教室搜索'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchTextChanged,
              decoration: const InputDecoration(
                labelText: '请输入想去的教室',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredClassrooms.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredClassrooms.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredClassrooms[index].name),
                        onTap: () {
                          Navigator.pop(context, [
                            _filteredClassrooms[index],
                          ]);
                        },
                      );
                    },
                  )
                : const Center(child: Text('无匹配教室')),
          ),
        ],
      ),
    );
  }
}
