package com.casuki.gbc_flutter.ui.screen

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController

sealed class Screen(val route: String, val title: String, val icon: androidx.compose.ui.graphics.vector.ImageVector) {
    object MyPlants : Screen("my_plants", "我的植物", Icons.Default.Eco)
    object CareReminder : Screen("care_reminder", "养护提醒", Icons.Default.Notifications)
    object PhotoIdentify : Screen("photo_identify", "拍照识别", Icons.Default.CameraAlt)
    object Diagnosis : Screen("diagnosis", "专业诊断", Icons.Default.MedicalServices)
    object Settings : Screen("settings", "应用设置", Icons.Default.Settings)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen() {
    val navController = rememberNavController()
    val screens = listOf(
        Screen.MyPlants,
        Screen.CareReminder,
        Screen.PhotoIdentify,
        Screen.Diagnosis,
        Screen.Settings
    )

    Scaffold(
        bottomBar = {
            NavigationBar {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentDestination = navBackStackEntry?.destination

                screens.forEach { screen ->
                    NavigationBarItem(
                        icon = { Icon(screen.icon, contentDescription = null) },
                        label = { Text(screen.title) },
                        selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController,
            startDestination = Screen.MyPlants.route,
            Modifier.padding(innerPadding)
        ) {
            composable(Screen.MyPlants.route) { MyPlantsScreen() }
            composable(Screen.CareReminder.route) { CareReminderScreen() }
            composable(Screen.PhotoIdentify.route) { PhotoIdentifyScreen() }
            composable(Screen.Diagnosis.route) { DiagnosisScreen() }
            composable(Screen.Settings.route) { SettingsScreen() }
        }
    }
}
