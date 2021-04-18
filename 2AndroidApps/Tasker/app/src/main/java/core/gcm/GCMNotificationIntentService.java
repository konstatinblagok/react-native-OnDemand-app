package core.gcm;

import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.a2zkaj.GcmBroadcastReceiver;
import com.a2zkaj.app.ChatPage;
import com.a2zkaj.app.MyJobs;
import com.a2zkaj.app.MyJobs_OnGoingDetailPage;
import com.a2zkaj.app.NavigationDrawer;
import com.a2zkaj.app.R;
import com.a2zkaj.app.ReviwesPage;

/**
 *
 */

public class GCMNotificationIntentService extends IntentService {
    GCMIntentManager notificationManager;
    String aMessagestr = "";
    String aJObIdStr = "";
    PendingIntent contentIntent;
    public static boolean isNotificationFlag = false;

    public GCMNotificationIntentService() {
        super("GCMNotificationIntentService");
    }

    public GCMNotificationIntentService(String name) {
        super(name);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        Bundle extras = intent.getExtras();
        GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
        String messageType = gcm.getMessageType(intent);
        notificationManager = new GCMIntentManager(getApplicationContext());


        if (!extras.isEmpty() && GoogleCloudMessaging.MESSAGE_TYPE_MESSAGE.equals(messageType)) {
            Log.e("extras", extras.toString());
            aMessagestr = extras.getString("gcm.notification.body");
            aJObIdStr = extras.getString("key0");

            sendNotification(aMessagestr, extras);
        }
        GcmBroadcastReceiver.completeWakefulIntent(intent);
    }

    private void sendNotification(String aMessagestr, Bundle aResponse) {

        Intent notificationIntent = null;

        if (aMessagestr.equalsIgnoreCase("You got a request for a new job")) {
            notificationIntent = new Intent(GCMNotificationIntentService.this, MyJobs_OnGoingDetailPage.class);
            notificationIntent.putExtra("JobId", aJObIdStr);
            notificationIntent.putExtra("status", "ongoing");
        } else if (aMessagestr.equalsIgnoreCase("Payment Completed")) {
            Intent broadcastIntentnavigation = new Intent();
            broadcastIntentnavigation.setAction("com.package.finish_LOADINGPAGE");
            sendBroadcast(broadcastIntentnavigation);
            notificationIntent = new Intent(GCMNotificationIntentService.this, ReviwesPage.class);
            notificationIntent.putExtra("jobId", aJObIdStr);
        } else if (aMessagestr.equalsIgnoreCase("User Cancelled this job")) {
            notificationIntent = new Intent(GCMNotificationIntentService.this, MyJobs.class);
        } else if (aResponse.toString().contains("user")) {
            notificationIntent = new Intent(GCMNotificationIntentService.this, ChatPage.class);
            notificationIntent.putExtra("TaskId", aResponse.getString("task"));
            notificationIntent.putExtra("TaskerId", aResponse.getString("user"));
        } else {
            notificationIntent = new Intent(GCMNotificationIntentService.this, NavigationDrawer.class);
        }

        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        PendingIntent contentIntent = PendingIntent.getActivity(GCMNotificationIntentService.this, 0, notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT);

        NotificationManager nm = (NotificationManager) GCMNotificationIntentService.this.getSystemService(Context.NOTIFICATION_SERVICE);
        Resources res = GCMNotificationIntentService.this.getResources();
        NotificationCompat.Builder builder = new NotificationCompat.Builder(GCMNotificationIntentService.this);
        builder.setSmallIcon(R.mipmap.handylogo)
                .setLargeIcon(BitmapFactory.decodeResource(res, R.mipmap.handylogo)).setTicker(aMessagestr)
                .setColor(getResources().getColor(R.color.app_color))
                .setWhen(System.currentTimeMillis()).setAutoCancel(true)
                .setContentTitle(getString(R.string.app_name))
                .setLights(0xffff0000, 100, 2000)
                .setPriority(Notification.DEFAULT_SOUND)
                .setPriority(Notification.DEFAULT_VIBRATE)
                .setContentText(aMessagestr)
                .setContentIntent(contentIntent)
                .setSound(Uri.parse("android.resource://com.maidacpartner/" + R.raw.notifysnd));
        isNotificationFlag = true;
        Notification n = builder.getNotification();
        n.defaults |= Notification.DEFAULT_ALL;
        nm.notify(0, n);
    }
}