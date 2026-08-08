package com.example.quran_app

import android.content.Context
import android.net.Uri
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.layout.Column
import androidx.glance.text.Text
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.actionStartActivity

class VerseGlanceWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val state = currentState<HomeWidgetGlanceState>()
            val arabicText = state.preferences.getString("arabicText", null)
            val verseId = state.preferences.getInt("id", -1)
            val isRead = state.preferences.getBoolean("isRead", false)

            Column(
                modifier = GlanceModifier.clickable(
                    actionStartActivity<MainActivity>(
                        context,
                        Uri.parse("homeWidget://toggleRead?id=$verseId"),
                    )
                )
            ) {
                Text(text = arabicText ?: "No verse loaded")
                Text(text = "Read: $isRead")
            }
        }
    }
}
