import 'dart:math';

import 'package:flutter/material.dart';

class PositionPainterService extends CustomPainter {
  double? direction;
  Offset? offset;
  late Path arrowPath;

  PositionPainterService({this.direction, this.offset}) {
    double arrowSize = 20;

    // 预先创建箭头路径
    arrowPath = Path();
    arrowPath.moveTo(-arrowSize / 2.5, arrowSize / 2);
    arrowPath.lineTo(0, -arrowSize / 2);
    arrowPath.lineTo(arrowSize / 2.5, arrowSize / 2);
    arrowPath.lineTo(0, arrowSize / 3.5);

    arrowPath.close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = offset!;

    // 规定箭头的颜色和样式
    final Paint blueArrowPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    // 当朝向不为空时（传感器收集到朝向），绘制箭头方向
    if (direction != null) {
      double rotateAngle = direction! * (pi / 180);
      canvas.save(); // 保存画布状态
      canvas.translate(center.dx, center.dy); // 平移画布
      canvas.rotate(rotateAngle); // 旋转画布

      canvas.drawPath(arrowPath, blueArrowPaint); // 绘制箭头

      canvas.restore(); // 恢复画布状态
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as PositionPainterService).direction != direction;
  }
}
