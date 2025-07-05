package com.casuki.gbc_flutter.data.api

import com.casuki.gbc_flutter.data.model.OpenAIRequest
import com.casuki.gbc_flutter.data.model.OpenAIResponse
import com.casuki.gbc_flutter.data.model.iNaturalistResponse
import okhttp3.MultipartBody
import retrofit2.Response
import retrofit2.http.*

interface iNaturalistApiService {
    @Multipart
    @POST("v1/identifications")
    suspend fun identifyPlant(
        @Part image: MultipartBody.Part,
        @Header("Authorization") token: String
    ): Response<iNaturalistResponse>
}

interface OpenAIApiService {
    @POST("v1/chat/completions")
    suspend fun analyzeImage(
        @Body request: OpenAIRequest,
        @Header("Authorization") authorization: String,
        @Header("Content-Type") contentType: String = "application/json"
    ): Response<OpenAIResponse>

    @POST("v1/chat/completions")
    suspend fun generateCareAdvice(
        @Body request: OpenAIRequest,
        @Header("Authorization") authorization: String,
        @Header("Content-Type") contentType: String = "application/json"
    ): Response<OpenAIResponse>
}
