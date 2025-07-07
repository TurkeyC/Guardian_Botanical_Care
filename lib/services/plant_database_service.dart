// Guardian Botanical Care (gbc_flutter)
// Copyright (C) 2025 <Cao Turkey>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/plant.dart';

class PlantDatabaseService {
  static Database? _database;
  static const String _tableName = 'plants';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 根据平台选择合适的数据库初始化方式
    if (Platform.isWindows || Platform.isLinux) {
      return await _initDesktopDatabase();
    } else {
      return await _initMobileDatabase();
    }
  }

  // 移动平台的数据库初始化
  Future<Database> _initMobileDatabase() async {
    String path = join(await getDatabasesPath(), 'plants.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 桌面平台的数据库初始化
  Future<Database> _initDesktopDatabase() async {
    // 确保 FFI 已初始化
    sqfliteFfiInit();
    // 获取桌面平台的数据库路径
    final databaseFactory = databaseFactoryFfi;
    String path = join(await databaseFactory.getDatabasesPath(), 'plants.db');
    // 使用 FFI 实现打开数据库
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        scientific_name TEXT,
        image_path TEXT NOT NULL,
        identification_date INTEGER NOT NULL,
        health_status TEXT NOT NULL,
        confidence REAL,
        care_instructions TEXT,
        watering_frequency TEXT,
        light_requirement TEXT,
        fertilizing_schedule TEXT
      )
    ''');
  }

  Future<int> insertPlant(Plant plant) async {
    final db = await database;
    return await db.insert(_tableName, _plantToMap(plant));
  }

  Future<List<Plant>> getAllPlants() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName,
        orderBy: 'identification_date DESC');
    return maps.map((map) => _plantFromMap(map)).toList();
  }

  Future<Plant?> getPlantById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _plantFromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePlant(Plant plant) async {
    final db = await database;
    return await db.update(
      _tableName,
      _plantToMap(plant),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  Future<int> deletePlant(String id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _plantToMap(Plant plant) {
    return {
      'id': plant.id,
      'name': plant.name,
      'scientific_name': plant.scientificName,
      'image_path': plant.imagePath,
      'identification_date': plant.identificationDate.millisecondsSinceEpoch,
      'health_status': plant.healthStatus,
      'confidence': plant.confidence,
      'care_instructions': plant.careInstructions,
      'watering_frequency': plant.wateringFrequency,
      'light_requirement': plant.lightRequirement,
      'fertilizing_schedule': plant.fertilizingSchedule,
    };
  }

  Plant _plantFromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'],
      name: map['name'],
      scientificName: map['scientific_name'] ?? '',
      imagePath: map['image_path'],
      identificationDate: DateTime.fromMillisecondsSinceEpoch(map['identification_date']),
      healthStatus: map['health_status'],
      confidence: map['confidence'] ?? 0.0,
      careInstructions: map['care_instructions'] ?? '',
      wateringFrequency: map['watering_frequency'] ?? '',
      lightRequirement: map['light_requirement'] ?? '',
      fertilizingSchedule: map['fertilizing_schedule'] ?? '',
    );
  }
}
