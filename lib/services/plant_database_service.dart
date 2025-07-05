import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    String path = join(await getDatabasesPath(), 'plants.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
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
