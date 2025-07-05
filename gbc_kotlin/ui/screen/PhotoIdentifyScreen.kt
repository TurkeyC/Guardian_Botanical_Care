package com.casuki.gbc_flutter.ui.screen

import android.Manifest
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.casuki.gbc_flutter.data.repository.PlantRepository
import com.casuki.gbc_flutter.data.repository.SettingsRepository
import com.casuki.gbc_flutter.ui.viewmodel.PlantIdentificationViewModel
import com.casuki.gbc_flutter.ui.viewmodel.PlantIdentificationViewModelFactory
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.isGranted
import com.google.accompanist.permissions.rememberPermissionState
import java.io.InputStream

@Preview(showBackground = true)
@Composable
fun PhotoIdentifyScreen(
    onNavigateBack: () -> Unit,
    onPhotoTaken: (String) -> Unit
) {
    var showCamera by remember { mutableStateOf(false) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        // 顶部工具栏
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
                .statusBarsPadding(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Top
        ) {
            IconButton(onClick = onNavigateBack) {
                Icon(
                    Icons.Default.Close,
                    contentDescription = "关闭",
                    tint = Color.White,
                    modifier = Modifier.size(24.dp)
                )
            }

            Row {
                IconButton(onClick = { /* 帮助功能 */ }) {
                    Icon(
                        Icons.Default.Help,
                        contentDescription = "帮助",
                        tint = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
                }
                IconButton(onClick = { /* 闪光灯切换 */ }) {
                    Icon(
                        Icons.Default.FlashOff,
                        contentDescription = "闪光灯",
                        tint = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
                }
                IconButton(onClick = { /* 切换摄像头 */ }) {
                    Icon(
                        Icons.Default.Refresh,
                        contentDescription = "切换摄像头",
                        tint = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
                }
            }
        }

        // 中心焦点框
        Box(
            modifier = Modifier
                .align(Alignment.Center)
                .width(280.dp)
                .height(380.dp)
                .border(
                    3.dp,
                    Color.White,
                    RoundedCornerShape(24.dp)
                )
                .background(
                    Color.Green.copy(alpha = 0.3f),
                    RoundedCornerShape(24.dp)
                )
        ) {
            // 中心横线
            Box(
                modifier = Modifier
                    .align(Alignment.Center)
                    .fillMaxWidth()
                    .height(2.dp)
                    .background(Color.Green)
            )

            // 提示文字
            Text(
                text = "将植物放在焦点中",
                color = Color.White.copy(alpha = 0.8f),
                fontSize = 16.sp,
                modifier = Modifier.align(Alignment.Center)
            )
        }

        // 底部拍照区域
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .height(120.dp)
                .background(Color.White)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.Center),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // 左侧按钮（相册）
                IconButton(
                    onClick = { /* 打开相册 */ },
                    modifier = Modifier
                        .size(60.dp)
                        .background(
                            Color.Gray,
                            CircleShape
                        )
                ) {
                    Icon(
                        Icons.Default.PhotoLibrary,
                        contentDescription = "相册",
                        tint = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
                }

                // 中心拍照按钮
                IconButton(
                    onClick = { /* 拍照逻辑 */ },
                    modifier = Modifier
                        .size(80.dp)
                        .background(
                            Color(0xFF4CAF50),
                            CircleShape
                        )
                ) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "拍照",
                        tint = Color.White,
                        modifier = Modifier.size(32.dp)
                    )
                }

                // 右侧按钮（预留）
                IconButton(
                    onClick = { /* 其他功能 */ },
                    modifier = Modifier
                        .size(60.dp)
                        .background(
                            Color.Gray,
                            CircleShape
                        )
                ) {
                    Icon(
                        Icons.Default.Settings,
                        contentDescription = "设置",
                        tint = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalPermissionsApi::class)
@Preview(showBackground = true)
@Composable
fun PhotoIdentifyScreenOld() {
    val context = LocalContext.current
    val settingsRepository = remember { SettingsRepository(context) }
    val plantRepository = remember { PlantRepository(context) }
    val viewModel: PlantIdentificationViewModel = viewModel(
        factory = PlantIdentificationViewModelFactory(plantRepository, settingsRepository)
    )

    val uiState by viewModel.uiState.collectAsState()
    var selectedImageBitmap by remember { mutableStateOf<Bitmap?>(null) }

    // 权限处理
    val cameraPermissionState = rememberPermissionState(Manifest.permission.CAMERA)

    // 相机拍照
    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicturePreview()
    ) { bitmap ->
        bitmap?.let {
            selectedImageBitmap = it
            viewModel.identifyPlant(it)
        }
    }

    // 相册选择
    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri ->
        uri?.let {
            val bitmap = loadBitmapFromUri(context, it)
            bitmap?.let { bmp ->
                selectedImageBitmap = bmp
                viewModel.identifyPlant(bmp)
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(rememberScrollState())
    ) {
        Text(
            text = "植物识别",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(16.dp))

        // 图片选择区域
        if (selectedImageBitmap == null && !uiState.isLoading) {
            ImageSelectionArea(
                onCameraClick = {
                    when {
                        cameraPermissionState.status.isGranted -> {
                            cameraLauncher.launch(null)
                        }
                        else -> {
                            cameraPermissionState.launchPermissionRequest()
                        }
                    }
                },
                onGalleryClick = {
                    galleryLauncher.launch("image/*")
                }
            )
        }

        // 选中的图片显示
        selectedImageBitmap?.let { bitmap ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(250.dp),
                elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
                shape = RoundedCornerShape(12.dp)
            ) {
                Image(
                    bitmap = bitmap.asImageBitmap(),
                    contentDescription = "选中的植物图片",
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }

            Spacer(modifier = Modifier.height(16.dp))
        }

        // 加载状态
        if (uiState.isLoading) {
            LoadingView()
        }

        // 错误显示
        uiState.error?.let { error ->
            ErrorView(error = error) {
                viewModel.clearResult()
                selectedImageBitmap = null
            }
        }

        // 识别结果
        uiState.identificationResult?.let { result ->
            IdentificationResultView(
                result = result,
                onAddToMyPlants = {
                    viewModel.addPlantToMyList(result)
                },
                onRetry = {
                    viewModel.clearResult()
                    selectedImageBitmap = null
                }
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun ImageSelectionArea(
    onCameraClick: () -> Unit,
    onGalleryClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(200.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = Icons.Default.AddAPhoto,
                contentDescription = null,
                modifier = Modifier.size(48.dp),
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "选择植物图片进行识别",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Button(
                    onClick = onCameraClick,
                    modifier = Modifier.weight(1f)
                ) {
                    Icon(
                        imageVector = Icons.Default.CameraAlt,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("拍照")
                }

                OutlinedButton(
                    onClick = onGalleryClick,
                    modifier = Modifier.weight(1f)
                ) {
                    Icon(
                        imageVector = Icons.Default.PhotoLibrary,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("相册")
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun LoadingView() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            CircularProgressIndicator()

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "正在识别植物...",
                style = MaterialTheme.typography.titleMedium
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "这可能需要几秒钟时间",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun ErrorView(error: String, onRetry: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.errorContainer
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = Icons.Default.Error,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onErrorContainer
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "识别失败",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onErrorContainer
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = error,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onErrorContainer,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(16.dp))

            Button(onClick = onRetry) {
                Text("重新识别")
            }
        }
    }
}

private fun loadBitmapFromUri(context: Context, uri: Uri): Bitmap? {
    return try {
        val inputStream: InputStream? = context.contentResolver.openInputStream(uri)
        BitmapFactory.decodeStream(inputStream)
    } catch (e: Exception) {
        null
    }
}
