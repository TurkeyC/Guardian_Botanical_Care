package com.casuki.gbc_flutter.data.model

import java.util.Date

data class Plant(
    val id: String,
    val name: String,
    val scientificName: String = "",
    val imagePath: String,
    val identificationDate: Date,
    val healthStatus: String,
    val confidence: Double = 0.0,
    val careInstructions: String = "",
    val wateringFrequency: String = "",
    val lightRequirement: String = "",
    val fertilizingSchedule: String = ""
)

data class PlantIdentificationResult(
    val species: String,
    val scientificName: String,
    val confidence: Double,
    val healthAnalysis: String,
    val careRecommendations: String,
    val imagePath: String
)

data class iNaturalistResponse(
    val results: List<iNaturalistResult>
)

data class iNaturalistResult(
    val taxon: Taxon,
    val score: Double
)

data class Taxon(
    val name: String,
    val preferred_common_name: String?
)

data class OpenAIRequest(
    val model: String,
    val messages: List<Message>,
    val max_tokens: Int = 1000
)

data class Message(
    val role: String,
    val content: List<Content>
)

data class Content(
    val type: String,
    val text: String? = null,
    val image_url: ImageUrl? = null
)

data class ImageUrl(
    val url: String
)

data class OpenAIResponse(
    val choices: List<Choice>
)

data class Choice(
    val message: ResponseMessage
)

data class ResponseMessage(
    val content: String
)
