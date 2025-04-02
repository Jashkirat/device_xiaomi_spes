/*
 * Copyright (C) 2025 kenway214
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings.gameoverlay;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import androidx.preference.PreferenceManager;

public class GameOverlayBootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (Intent.ACTION_BOOT_COMPLETED.equals(action)
                || Intent.ACTION_LOCKED_BOOT_COMPLETED.equals(action)) {
            restoreOverlayState(context);
        }
    }

    private void restoreOverlayState(Context context) {
        var prefs = PreferenceManager.getDefaultSharedPreferences(context);
        boolean enabled = prefs.getBoolean("game_overlay_enable", false);
        GameOverlay overlay = GameOverlay.getInstance(context);
        if (!enabled) {
            overlay.hide();
            return;
        }
        
        overlay.applyPreferences();
        overlay.show();
    }
}
