package com.casuki.gbc_flutter.ui.screen

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.casuki.gbc_flutter.data.repository.SettingsRepository
import com.casuki.gbc_flutter.ui.viewmodel.SettingsViewModel
import com.casuki.gbc_flutter.ui.viewmodel.SettingsViewModelFactory

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen() {
    val context = LocalContext.current
    val settingsRepository = remember { SettingsRepository(context) }
    val viewModel: SettingsViewModel = viewModel(
        factory = SettingsViewModelFactory(settingsRepository)
    )

    val uiState by viewModel.uiState.collectAsState()

    // 本地状态变量
    var iNaturalistApiUrl by remember { mutableStateOf("") }
    var iNaturalistToken by remember { mutableStateOf("") }
    var openAIApiUrl by remember { mutableStateOf("") }
    var openAIToken by remember { mutableStateOf("") }
    var visionModelName by remember { mutableStateOf("") }
    var llmModelName by remember { mutableStateOf("") }

    // 当从ViewModel加载数据时更新本地状态
    LaunchedEffect(uiState) {
        if (iNaturalistApiUrl.isEmpty()) iNaturalistApiUrl = uiState.iNaturalistApiUrl
        if (iNaturalistToken.isEmpty()) iNaturalistToken = uiState.iNaturalistToken
        if (openAIApiUrl.isEmpty()) openAIApiUrl = uiState.openAIApiUrl
        if (openAIToken.isEmpty()) openAIToken = uiState.openAIToken
        if (visionModelName.isEmpty()) visionModelName = uiState.visionModelName
        if (llmModelName.isEmpty()) llmModelName = uiState.llmModelName
    }

    // 显示保存消息
    uiState.saveMessage?.let { message ->
        LaunchedEffect(message) {
            kotlinx.coroutines.delay(2000)
            viewModel.clearSaveMessage()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(rememberScrollState())
    ) {
        Text(
            text = "应用设置",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(16.dp))

        // iNaturalist 设置
        iNaturalistSettingsSection(
            apiUrl = iNaturalistApiUrl,
            token = iNaturalistToken,
            onApiUrlChange = { iNaturalistApiUrl = it },
            onTokenChange = { iNaturalistToken = it },
            onSave = { viewModel.updateiNaturalistSettings(iNaturalistApiUrl, iNaturalistToken) }
        )

        Spacer(modifier = Modifier.height(16.dp))

        // OpenAI 设置
        OpenAISettingsSection(
            apiUrl = openAIApiUrl,
            token = openAIToken,
            visionModel = visionModelName,
            llmModel = llmModelName,
            onApiUrlChange = { openAIApiUrl = it },
            onTokenChange = { openAIToken = it },
            onVisionModelChange = { visionModelName = it },
            onLlmModelChange = { llmModelName = it },
            onSave = {
                viewModel.updateOpenAISettings(
                    openAIApiUrl,
                    openAIToken,
                    visionModelName,
                    llmModelName
                )
            }
        )

        Spacer(modifier = Modifier.height(16.dp))

        // 使用说明
        UsageInstructionsSection()

        // 保存消息显示
        uiState.saveMessage?.let { message ->
            Spacer(modifier = Modifier.height(16.dp))
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                ),
                shape = RoundedCornerShape(8.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = message,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                }
            }
        }
    }
}

@Composable
fun iNaturalistSettingsSection(
    apiUrl: String,
    token: String,
    onApiUrlChange: (String) -> Unit,
    onTokenChange: (String) -> Unit,
    onSave: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Nature,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "iNaturalist 设置",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = apiUrl,
                onValueChange = onApiUrlChange,
                label = { Text("API 地址") },
                placeholder = { Text("https://api.inaturalist.org/") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true
            )

            Spacer(modifier = Modifier.height(12.dp))

            OutlinedTextField(
                value = token,
                onValueChange = onTokenChange,
                label = { Text("API Token") },
                placeholder = { Text("输入您的 iNaturalist API Token") },
                modifier = Modifier.fillMaxWidth(),
                visualTransformation = PasswordVisualTransformation(),
                singleLine = true
            )

            Spacer(modifier = Modifier.height(16.dp))

            Button(
                onClick = onSave,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("保存 iNaturalist 设置")
            }
        }
    }
}

@Composable
fun OpenAISettingsSection(
    apiUrl: String,
    token: String,
    visionModel: String,
    llmModel: String,
    onApiUrlChange: (String) -> Unit,
    onTokenChange: (String) -> Unit,
    onVisionModelChange: (String) -> Unit,
    onLlmModelChange: (String) -> Unit,
    onSave: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Psychology,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.secondary
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "AI 模型设置",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = apiUrl,
                onValueChange = onApiUrlChange,
                label = { Text("API 地址") },
                placeholder = { Text("https://api.openai.com/") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true
            )

            Spacer(modifier = Modifier.height(12.dp))

            OutlinedTextField(
                value = token,
                onValueChange = onTokenChange,
                label = { Text("API Key") },
                placeholder = { Text("输入您的 OpenAI API Key") },
                modifier = Modifier.fillMaxWidth(),
                visualTransformation = PasswordVisualTransformation(),
                singleLine = true
            )

            Spacer(modifier = Modifier.height(12.dp))

            OutlinedTextField(
                value = visionModel,
                onValueChange = onVisionModelChange,
                label = { Text("视觉模型名称") },
                placeholder = { Text("gpt-4-vision-preview") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true
            )

            Spacer(modifier = Modifier.height(12.dp))

            OutlinedTextField(
                value = llmModel,
                onValueChange = onLlmModelChange,
                label = { Text("语言模型名称") },
                placeholder = { Text("gpt-4") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true
            )

            Spacer(modifier = Modifier.height(16.dp))

            Button(
                onClick = onSave,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("保存 AI 模型设置")
            }
        }
    }
}

@Composable
fun UsageInstructionsSection() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Info,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "使用说明",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Text(
                text = """
                    • iNaturalist 用于植物品种识别，需要注册账号获取 API Token
                    • OpenAI 模型用于健康分析和养护建议生成
                    • 支持兼容 OpenAI API 的其他服务（如国内厂商API）
                    • 首次使用前请确保配置正确的 API 地址和密钥
                    • 所有数据仅在本地存储，不会上传到云端
                """.trimIndent(),
                style = MaterialTheme.typography.bodyMedium,
                lineHeight = MaterialTheme.typography.bodyMedium.lineHeight * 1.4
            )
        }
    }
}
