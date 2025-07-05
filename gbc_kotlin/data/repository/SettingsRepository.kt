package com.casuki.gbc_flutter.data.repository

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.casuki.gbc_flutter.data.model.Plant
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

class SettingsRepository(private val context: Context) {

    companion object {
        val INATURALIST_API_URL = stringPreferencesKey("inaturalist_api_url")
        val INATURALIST_TOKEN = stringPreferencesKey("inaturalist_token")
        val OPENAI_API_URL = stringPreferencesKey("openai_api_url")
        val OPENAI_TOKEN = stringPreferencesKey("openai_token")
        val VISION_MODEL_NAME = stringPreferencesKey("vision_model_name")
        val LLM_MODEL_NAME = stringPreferencesKey("llm_model_name")
        val MY_PLANTS = stringPreferencesKey("my_plants")
    }

    // API设置相关方法
    suspend fun saveiNaturalistSettings(apiUrl: String, token: String) {
        context.dataStore.edit { preferences ->
            preferences[INATURALIST_API_URL] = apiUrl
            preferences[INATURALIST_TOKEN] = token
        }
    }

    suspend fun saveOpenAISettings(apiUrl: String, token: String, visionModel: String, llmModel: String) {
        context.dataStore.edit { preferences ->
            preferences[OPENAI_API_URL] = apiUrl
            preferences[OPENAI_TOKEN] = token
            preferences[VISION_MODEL_NAME] = visionModel
            preferences[LLM_MODEL_NAME] = llmModel
        }
    }

    fun getiNaturalistApiUrl(): Flow<String> {
        return context.dataStore.data.map { preferences ->
            preferences[INATURALIST_API_URL] ?: "https://api.inaturalist.org/"
        }
    }

    fun getiNaturalistToken(): Flow<String> {
        return context.dataStore.data.map { preferences ->
            preferences[INATURALIST_TOKEN] ?: ""
        }
    }

    fun getOpenAIApiUrl(): Flow<String> {
        return context.dataStore.data.map { preferences ->
            preferences[OPENAI_API_URL] ?: "https://api.openai.com/"
        }
    }

    fun getOpenAIToken(): Flow<String> {
        return context.dataStore.data.map { preferences ->
            preferences[OPENAI_TOKEN] ?: ""
        }
    }

    fun getVisionModelName(): Flow<String> {
        return context.dataStore.data.map { preferences ->
            preferences[VISION_MODEL_NAME] ?: "gpt-4-vision-preview"
        }
    }

    fun getLLMModelName(): Flow<String> {
        return context.dataStore.data.map { preferences ->
            preferences[LLM_MODEL_NAME] ?: "gpt-4"
        }
    }

    // 植物数据管理
    suspend fun saveMyPlants(plants: List<Plant>) {
        val gson = Gson()
        val plantsJson = gson.toJson(plants)
        context.dataStore.edit { preferences ->
            preferences[MY_PLANTS] = plantsJson
        }
    }

    fun getMyPlants(): Flow<List<Plant>> {
        return context.dataStore.data.map { preferences ->
            val plantsJson = preferences[MY_PLANTS] ?: "[]"
            val gson = Gson()
            val type = object : TypeToken<List<Plant>>() {}.type
            gson.fromJson(plantsJson, type) ?: emptyList()
        }
    }

    suspend fun addPlant(plant: Plant) {
        context.dataStore.edit { preferences ->
            val currentPlantsJson = preferences[MY_PLANTS] ?: "[]"
            val gson = Gson()
            val type = object : TypeToken<List<Plant>>() {}.type
            val currentPlants: MutableList<Plant> = gson.fromJson(currentPlantsJson, type) ?: mutableListOf()
            currentPlants.add(plant)
            preferences[MY_PLANTS] = gson.toJson(currentPlants)
        }
    }
}
