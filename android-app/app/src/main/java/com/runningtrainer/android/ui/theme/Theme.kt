package com.runningtrainer.android.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val RunningTrainerColors = darkColorScheme(
    primary = Primary,
    secondary = Secondary,
    background = Background,
    surface = Surface,
    onPrimary = Background,
    onSecondary = Background,
    onBackground = OnDark,
    onSurface = OnDark
)

@Composable
fun RunningTrainerTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = RunningTrainerColors,
        typography = Typography,
        content = content
    )
}

