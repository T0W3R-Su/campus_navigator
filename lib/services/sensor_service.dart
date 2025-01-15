import 'dart:async';
import 'dart:math';

import 'package:campus_navigator/services/direction_painter_service.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';

class SensorService extends StatefulWidget {
  Offset? offset;
  SensorService({super.key, required this.offset});

  @override
  _SensorServiceState createState() => _SensorServiceState();
}

class _SensorServiceState extends State<SensorService> {
  final _streamSubscriptions = <StreamSubscription<dynamic>>[]; // 传感器流订阅
  double? direction = 0; // 方向

  @override
  void initState() {
    super.initState();

    _streamSubscriptions.add(
      // 加速度传感器流
      userAccelerometerEventStream(
              samplingPeriod: const Duration(milliseconds: 100))
          .listen((UserAccelerometerEvent event) {
            // 出现较大的加速度时，更新偏移量，只处理向前行走的情况
        setState(() {
          if (event.y.abs() < 2 && event.y.abs() > 0.5) {
            // 考虑实际行走的朝向与正北的夹角
            widget.offset = widget.offset! +
                Offset(-event.y * 0.3 * sin(direction! * pi / 180),
                    event.y * 0.3 * cos(direction! * pi / 180));
          }
        });
      }),
    );
  }

  @override
  void dispose() {
    // 取消所有的流订阅
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        // 如果有数据，绘制方向
        if (snapshot.hasData) {
          direction = snapshot.data!.heading;
          return Stack(
            children: [
              // 绘制当前位置和方向
              LayoutBuilder(
                builder: (context, constraints) => CustomPaint(
                  painter: PositionPainterService(
                      direction: direction, offset: widget.offset),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
              )
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // 显示加载动画
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
