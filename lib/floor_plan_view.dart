import 'dart:async';

import 'package:campus_navigator/search_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'models/classroom.dart'; // 教室模型
import 'services/sensor_service.dart'; // 传感器服务
import 'package:flutter/services.dart'; // 用于加载图片

class FloorPlanView extends StatefulWidget {
  // 教室模型
  final Classroom classroom;

  const FloorPlanView({super.key, required this.classroom});

  @override
  _FloorPlanViewState createState() => _FloorPlanViewState();
}

class _FloorPlanViewState extends State<FloorPlanView> {
  ImageProvider? _floorPlanImage; // 图片提供
  Offset? _markerPosition; // 标记位置
  Classroom? targetClassroom; // 目标教室
  final GlobalKey _imageKey = GlobalKey(); // 图片的全局键 根据实际的图片大小计算正确的标记位置
  Size _imageSize = Size.zero; // 图片大小

  @override
  void initState() {
    super.initState();
    _loadFloorPlanAndMarker(widget.classroom);
  }

  /*
  * 通过教室的建筑号和楼层加载正确的平面图
  */
  Future<void> _loadFloorPlanAndMarker(Classroom classroom) async {
    // Load the correct floor plan image based on the classroom's building and floor.
    String imageName =
        '${classroom.building.toLowerCase()}_${classroom.floor}th_floor.png';
    String imagePath = 'assets/$imageName';

    // 从 assets 文件夹中加载图片数据
    final ByteData data = await rootBundle.load(imagePath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
      return completer.complete(img);
    });

    // 设置图片提供
    setState(() {
      _floorPlanImage = MemoryImage(data.buffer.asUint8List());
      _markerPosition = Offset(classroom.coordinates['x'] ?? 0,
          classroom.coordinates['y'] ?? 0); // 获取教室位置
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Floor ${widget.classroom.floor} - ${widget.classroom.name}'),
        actions: [
          // 搜索按钮 用于搜索目标教室
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              // 等待并获取搜索页面返回的结果
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TargetSearchPage()),
              );

              // 如果结果不为空，则尝试更新目标教室
              if (result != null && result.isNotEmpty) {
                // 如果目标教室不在同一楼层，则显示消息
                if (result[0].floor != widget.classroom.floor) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('目标教室不在同一楼层！'),
                    ),
                  );
                } else {
                  setState(() {
                    targetClassroom = result[0];
                  });
                }
              }
            },
          )
        ],
      ),
      body: _floorPlanImage != null && _markerPosition != null
          ? Column(
              // 设置主轴对齐方式和交叉轴对齐方式
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // 使用 Stack 将图片和标记叠加在一起
                Expanded(
                  child: Stack(
                    fit: StackFit.loose,
                    children: <Widget>[
                      // 使用 LayoutBuilder 获取图片的大小 以便计算标记的位置
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // 当图片大小为空时，尝试获取图片的大小
                          if (_imageSize == Size.zero) {
                            // 回调函数在每次布局完成后执行
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              RenderBox renderBox = _imageKey.currentContext!
                                  .findRenderObject() as RenderBox;
                              // 设定图片大小
                              setState(() {
                                _imageSize = renderBox.size;
                              });
                            });
                          }
                          // 显示图片
                          return Image(
                            image: _floorPlanImage!,
                            fit: BoxFit.contain,
                            key: _imageKey,
                          );
                        },
                      ),
                      // 调用传感器服务
                      SensorService(
                          offset: Offset(_markerPosition!.dx * _imageSize.width,
                              _markerPosition!.dy * _imageSize.height)),

                      // 如果目标教室不为空，则显示目标教室的位置
                      if (targetClassroom != null)
                        Positioned(
                          left: targetClassroom!.coordinates['x']! *
                                  _imageSize.width -
                              15,
                          top: targetClassroom!.coordinates['y']! *
                                  _imageSize.height -
                              30,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 30),
                        ),
                    ],
                  ),
                ),
                // 提示用户如何选择目标教室
                Container(
                  padding: const EdgeInsets.all(16.0), // 设置内边距，可以根据需要调整数值
                  decoration: BoxDecoration(
                    color: Colors.grey, // 背景颜色
                    borderRadius: BorderRadius.circular(12.0), // 设置圆角半径
                  ),
                  child: const Text(
                    '点击右上角搜索，选择目标教室',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
