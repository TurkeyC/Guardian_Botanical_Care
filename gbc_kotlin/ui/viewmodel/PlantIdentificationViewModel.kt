package com.casuki.gbc_flutter.ui.viewmodel

import android.graphics.Bitmap
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.casuki.gbc_flutter.data.model.Plant
import com.casuki.gbc_flutter.data.model.PlantIdentificationResult
import com.casuki.gbc_flutter.data.repository.PlantRepository
import com.casuki.gbc_flutter.data.repository.SettingsRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.*

class PlantIdentificationViewModel(
    private val plantRepository: PlantRepository,
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(PlantIdentificationUiState())
    val uiState: StateFlow<PlantIdentificationUiState> = _uiState.asStateFlow()

    private val _myPlants = MutableStateFlow<List<Plant>>(emptyList())
    val myPlants: StateFlow<List<Plant>> = _myPlants.asStateFlow()

    init {
        loadMyPlants()
    }

    fun identifyPlant(imageBitmap: Bitmap) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)

            try {
                val result = plantRepository.identifyPlant(imageBitmap)
                if (result.isSuccess) {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        identificationResult = result.getOrNull()
                    )
                } else {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = result.exceptionOrNull()?.message ?: "识别失败"
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "未知错误"
                )
            }
        }
    }

    fun addPlantToMyList(identificationResult: PlantIdentificationResult) {
        viewModelScope.launch {
            val plant = Plant(
                id = UUID.randomUUID().toString(),
                name = identificationResult.species,
                scientificName = identificationResult.scientificName,
                imagePath = identificationResult.imagePath,
                identificationDate = Date(),
                healthStatus = identificationResult.healthAnalysis,
                confidence = identificationResult.confidence,
                careInstructions = identificationResult.careRecommendations
            )

            settingsRepository.addPlant(plant)
            loadMyPlants()
        }
    }

    private fun loadMyPlants() {
        viewModelScope.launch {
            settingsRepository.getMyPlants().collect { plants ->
                _myPlants.value = plants
            }
        }
    }

    fun clearResult() {
        _uiState.value = PlantIdentificationUiState()
    }
}

data class PlantIdentificationUiState(
    val isLoading: Boolean = false,
    val identificationResult: PlantIdentificationResult? = null,
    val error: String? = null
)

class PlantIdentificationViewModelFactory(
    private val plantRepository: PlantRepository,
    private val settingsRepository: SettingsRepository
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(PlantIdentificationViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return PlantIdentificationViewModel(plantRepository, settingsRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
