import 'package:flutter/foundation.dart';
import '../models/plant.dart';
import '../services/plant_database_service.dart';

class PlantProvider extends ChangeNotifier {
  final PlantDatabaseService _databaseService = PlantDatabaseService();

  List<Plant> _plants = [];
  bool _isLoading = false;
  String? _error;

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载所有植物
  Future<void> loadPlants() async {
    _setLoading(true);
    try {
      _plants = await _databaseService.getAllPlants();
      _error = null;
    } catch (e) {
      _error = '加载植物数据失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// 添加新植物
  Future<bool> addPlant(Plant plant) async {
    try {
      await _databaseService.insertPlant(plant);
      _plants.insert(0, plant);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '添加植物失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 更新植物信息
  Future<bool> updatePlant(Plant plant) async {
    try {
      await _databaseService.updatePlant(plant);
      final index = _plants.indexWhere((p) => p.id == plant.id);
      if (index != -1) {
        _plants[index] = plant;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = '更新植物信息失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 删除植物
  Future<bool> deletePlant(String plantId) async {
    try {
      await _databaseService.deletePlant(plantId);
      _plants.removeWhere((plant) => plant.id == plantId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '删除植物失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 根据ID获取植物
  Plant? getPlantById(String id) {
    try {
      return _plants.firstWhere((plant) => plant.id == id);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
