package com.runningtrainer.android.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val RunningTrainerColors = darkColorScheme(
    primary            = Primary,
    secondary          = Secondary,
    tertiary           = Tertiary,
    tertiaryContainer  = TertiaryContainer,
    background         = Background,
    surface            = Surface,
    surfaceVariant     = SurfaceVar,
    error              = ErrorRed,
    onPrimary          = Background,
    onSecondary        = Background,
    onTertiary         = Background,
    onBackground       = OnDark,
    onSurface          = OnDark,
    onSurfaceVariant   = TextMuted,
    onError            = OnDark
)

@Composable
fun RunningTrainerTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = RunningTrainerColors,
        typography  = Typography,
        content     = content
    )
}
