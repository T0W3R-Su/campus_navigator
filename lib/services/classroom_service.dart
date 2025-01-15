import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:campus_navigator/models/classroom.dart';

class ClassroomService {
  bool matchClassroom(String input, String classroomName) {
    // 去掉输入中的所有空格，并转换为大写，以便进行比较
    input = input.replaceAll(' ', '').toUpperCase();
    classroomName = classroomName.toUpperCase();

    // 如果输入是教室名的前缀，则返回 true
    if (classroomName.startsWith(input)) {
      return true;
    }

    // 输入分离字母和数字部分进行检查
    String lettersInput = '';
    String numbersInput = '';

    if (input.isNotEmpty && input[0].contains(RegExp(r'[A-Z]'))) {
      int index = input.indexOf(RegExp(r'[^A-Z]'));
      if (index == -1) index = input.length; // 全部是字母的情况
      lettersInput = input.substring(0, index);
      numbersInput = input.substring(index);
    } else {
      numbersInput = input;
    }

    // 教室名也分离字母和数字部分
    String lettersClassroom = classroomName.substring(0, 1); 
    String numbersClassroom = classroomName.substring(1); 

    // 检查字母部分是否完全匹配
    if (lettersInput.isNotEmpty && lettersClassroom != lettersInput) {
      return false;
    }

    // 检查数字部分是否完全匹配
    bool isMatch = false;
    if (numbersInput.isNotEmpty) {
      for (int i = 0; i <= numbersClassroom.length - numbersInput.length; i++) {
        if (numbersClassroom.substring(i, i + numbersInput.length) ==
            numbersInput) {
          isMatch = true;
          break;
        }
      }
    }

    return isMatch;
  }

  Future<List<Classroom>> getClassroomsByPrefix(String userInput) async {
    // 从 assets/classrooms.json 文件中加载教室数据
    final String response =
        await rootBundle.loadString('assets/classrooms.json');
    final data = await json.decode(response);

    // 从数据中提取教室列表
    List<dynamic> classroomsData = data['classrooms'];

    // 对每个教室进行匹配
    List<Classroom> matchedClassrooms = classroomsData
        .where((classroom) => matchClassroom(userInput, classroom['name']))
        .map((classroom) => Classroom.fromJson(classroom))
        .toList();

    return matchedClassrooms;
  }
}
