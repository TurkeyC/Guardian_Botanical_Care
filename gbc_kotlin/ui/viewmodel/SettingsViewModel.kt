package com.casuki.gbc_flutter.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.casuki.gbc_flutter.data.repository.SettingsRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class SettingsViewModel(
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    init {
        loadSettings()
    }

    private fun loadSettings() {
        viewModelScope.launch {
            settingsRepository.getiNaturalistApiUrl().collect { url ->
                _uiState.value = _uiState.value.copy(iNaturalistApiUrl = url)
            }
        }
        viewModelScope.launch {
            settingsRepository.getiNaturalistToken().collect { token ->
                _uiState.value = _uiState.value.copy(iNaturalistToken = token)
            }
        }
        viewModelScope.launch {
            settingsRepository.getOpenAIApiUrl().collect { url ->
                _uiState.value = _uiState.value.copy(openAIApiUrl = url)
            }
        }
        viewModelScope.launch {
            settingsRepository.getOpenAIToken().collect { token ->
                _uiState.value = _uiState.value.copy(openAIToken = token)
            }
        }
        viewModelScope.launch {
            settingsRepository.getVisionModelName().collect { model ->
                _uiState.value = _uiState.value.copy(visionModelName = model)
            }
        }
        viewModelScope.launch {
            settingsRepository.getLLMModelName().collect { model ->
                _uiState.value = _uiState.value.copy(llmModelName = model)
            }
        }
    }

    fun updateiNaturalistSettings(apiUrl: String, token: String) {
        viewModelScope.launch {
            settingsRepository.saveiNaturalistSettings(apiUrl, token)
            _uiState.value = _uiState.value.copy(
                isSaving = false,
                saveMessage = "iNaturalist设置已保存"
            )
        }
    }

    fun updateOpenAISettings(apiUrl: String, token: String, visionModel: String, llmModel: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSaving = true)
            settingsRepository.saveOpenAISettings(apiUrl, token, visionModel, llmModel)
            _uiState.value = _uiState.value.copy(
                isSaving = false,
                saveMessage = "OpenAI设置已保存"
            )
        }
    }

    fun clearSaveMessage() {
        _uiState.value = _uiState.value.copy(saveMessage = null)
    }
}

data class SettingsUiState(
    val iNaturalistApiUrl: String = "",
    val iNaturalistToken: String = "",
    val openAIApiUrl: String = "",
    val openAIToken: String = "",
    val visionModelName: String = "",
    val llmModelName: String = "",
    val isSaving: Boolean = false,
    val saveMessage: String? = null
)

class SettingsViewModelFactory(
    private val settingsRepository: SettingsRepository
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(SettingsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return SettingsViewModel(settingsRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
