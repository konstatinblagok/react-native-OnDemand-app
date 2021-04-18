package com.a2zkaj;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.support.v4.content.WakefulBroadcastReceiver;
import android.util.Log;

import core.gcm.GCMNotificationIntentService;

/**
 * Created by user145 on 7/26/2017.
 */
public class GcmBroadcastReceiver extends WakefulBroadcastReceiver {


    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            Log.e("REceiver", "Enter");
            ComponentName comp = new ComponentName(context.getPackageName(), GCMNotificationIntentService.class.getName());
            startWakefulService(context, (intent.setComponent(comp)));
        } catch (Exception e) {
        }
    }
}
