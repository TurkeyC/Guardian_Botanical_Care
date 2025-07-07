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
