package com.casuki.gbc_flutter.data.repository

import android.content.Context
import android.graphics.Bitmap
import android.util.Base64
import com.casuki.gbc_flutter.data.api.ApiClient
import com.casuki.gbc_flutter.data.model.*
import kotlinx.coroutines.flow.first
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream

class PlantRepository(private val context: Context) {

    private val settingsRepository = SettingsRepository(context)

    suspend fun identifyPlant(imageBitmap: Bitmap): Result<PlantIdentificationResult> {
        return try {
            // 保存图片到本地
            val imageFile = saveImageToFile(imageBitmap)

            // 步骤1: 使用iNaturalist识别植物品种
            val identificationResult = identifyWithiNaturalist(imageFile)

            // 步骤2: 使用视觉大模型分析健康状况
            val healthAnalysis = analyzeHealthWithVision(imageBitmap)

            // 步骤3: 生成养护建议
            val careAdvice = generateCareAdvice(identificationResult, healthAnalysis)

            val result = PlantIdentificationResult(
                species = identificationResult.first,
                scientificName = identificationResult.second,
                confidence = identificationResult.third,
                healthAnalysis = healthAnalysis,
                careRecommendations = careAdvice,
                imagePath = imageFile.absolutePath
            )

            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private suspend fun identifyWithiNaturalist(imageFile: File): Triple<String, String, Double> {
        val apiUrl = settingsRepository.getiNaturalistApiUrl().first()
        val token = settingsRepository.getiNaturalistToken().first()

        val service = ApiClient.createiNaturalistService(apiUrl)

        val requestFile = imageFile.asRequestBody("image/*".toMediaTypeOrNull())
        val imagePart = MultipartBody.Part.createFormData("image", imageFile.name, requestFile)

        val response = service.identifyPlant(imagePart, "Bearer $token")

        if (response.isSuccessful && response.body() != null) {
            val result = response.body()!!
            if (result.results.isNotEmpty()) {
                val topResult = result.results.first()
                return Triple(
                    topResult.taxon.preferred_common_name ?: topResult.taxon.name,
                    topResult.taxon.name,
                    topResult.score
                )
            }
        }

        // 如果API调用失败，返回默认值
        return Triple("未知植物", "Unknown species", 0.0)
    }

    private suspend fun analyzeHealthWithVision(imageBitmap: Bitmap): String {
        val apiUrl = settingsRepository.getOpenAIApiUrl().first()
        val token = settingsRepository.getOpenAIToken().first()
        val model = settingsRepository.getVisionModelName().first()

        if (token.isEmpty()) {
            return "请在设置中配置OpenAI API密钥以启用健康分析功能"
        }

        val service = ApiClient.createOpenAIService(apiUrl)

        // 将图片转换为base64
        val base64Image = bitmapToBase64(imageBitmap)

        val request = OpenAIRequest(
            model = model,
            messages = listOf(
                Message(
                    role = "user",
                    content = listOf(
                        Content(
                            type = "text",
                            text = "请分析这张植物图片的健康状况。请重点关注以下方面：1. 叶片颜色和形状 2. 是否有病虫害迹象 3. 整体生长状态 4. 任何异常症状。请用中文回答，并保持简洁。"
                        ),
                        Content(
                            type = "image_url",
                            image_url = ImageUrl(url = "data:image/jpeg;base64,$base64Image")
                        )
                    )
                )
            )
        )

        return try {
            val response = service.analyzeImage(request, "Bearer $token")
            if (response.isSuccessful && response.body() != null) {
                response.body()!!.choices.firstOrNull()?.message?.content ?: "分析失败"
            } else {
                "健康分析服务暂时不可用"
            }
        } catch (e: Exception) {
            "健康分析出错: ${e.message}"
        }
    }

    private suspend fun generateCareAdvice(
        identificationResult: Triple<String, String, Double>,
        healthAnalysis: String
    ): String {
        val apiUrl = settingsRepository.getOpenAIApiUrl().first()
        val token = settingsRepository.getOpenAIToken().first()
        val model = settingsRepository.getLLMModelName().first()

        if (token.isEmpty()) {
            return "请在设置中配置OpenAI API密钥以启用养护建议功能"
        }

        val service = ApiClient.createOpenAIService(apiUrl)

        val prompt = """
            基于以下信息，请为用户提供详细的植物养护建议：
            
            植物品种：${identificationResult.first}
            学名：${identificationResult.second}
            识别置信度：${String.format("%.2f", identificationResult.third * 100)}%
            
            健康状况分析：
            $healthAnalysis
            
            请提供以下方面的具体建议：
            1. 浇水频率和方法
            2. 光照要求
            3. 施肥建议
            4. 适宜的生长环境
            5. 常见问题预防
            
            请用中文回答，条理清晰，实用性强。
        """.trimIndent()

        val request = OpenAIRequest(
            model = model,
            messages = listOf(
                Message(
                    role = "user",
                    content = listOf(
                        Content(
                            type = "text",
                            text = prompt
                        )
                    )
                )
            )
        )

        return try {
            val response = service.generateCareAdvice(request, "Bearer $token")
            if (response.isSuccessful && response.body() != null) {
                response.body()!!.choices.firstOrNull()?.message?.content ?: "建议生成失败"
            } else {
                "养护建议服务暂时不可用"
            }
        } catch (e: Exception) {
            "养护建议生成出错: ${e.message}"
        }
    }

    private fun saveImageToFile(bitmap: Bitmap): File {
        val file = File(context.filesDir, "plant_${System.currentTimeMillis()}.jpg")
        val outputStream = FileOutputStream(file)
        bitmap.compress(Bitmap.CompressFormat.JPEG, 85, outputStream)
        outputStream.close()
        return file
    }

    private fun bitmapToBase64(bitmap: Bitmap): String {
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 85, byteArrayOutputStream)
        val byteArray = byteArrayOutputStream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.NO_WRAP)
    }
}
