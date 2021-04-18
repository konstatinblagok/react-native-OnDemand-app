package com.a2zkaj.FCM;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.a2zkaj.app.ChatPage;
import com.a2zkaj.app.MyJobs;
import com.a2zkaj.app.MyJobs_OnGoingDetailPage;
import com.a2zkaj.app.NavigationDrawer;
import com.a2zkaj.app.NewLeadsPage;
import com.a2zkaj.app.R;
import com.a2zkaj.app.ReviwesPage;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by user145 on 8/4/2017.
 */
public class MyFirebaseMessagingService extends FirebaseMessagingService {

    private static final String TAG = MyFirebaseMessagingService.class.getSimpleName();

    private NotificationUtils notificationUtils;
    private String Job_status_message="";
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.e(TAG, "From: " + remoteMessage.getFrom());
        System.out.println("--------FCM Received-------"+remoteMessage);
        if (remoteMessage == null)
            return;

        // Check if message contains a notification payload.
        if (remoteMessage.getNotification() != null) {
            Log.e(TAG, "Notification Body: " + remoteMessage.getNotification().getBody());
            handleNotification(remoteMessage.getNotification().getBody());
        }

        // Check if message contains a data payload.
        if (remoteMessage.getData().size() > 0) {
            Log.e(TAG, "Data Payload: " + remoteMessage.getData().toString());

            try {
                JSONObject json = new JSONObject(remoteMessage.getData().toString());
                handleDataMessage(json);
            } catch (Exception e) {
                Log.e(TAG, "Exception: " + e.getMessage());
            }
        }
    }

    private void handleNotification(String message) {
        Job_status_message=message;
    }

    private void handleDataMessage(JSONObject json) {
        Log.e(TAG, "push json: " + json.toString());
        String imageUrl="";
        String message="";
        String title="";
        String task_id="";
        String tasker_id="";
        String timestamp="";
        String job_id="";
        Intent resultIntent = null;
        String user_id="";
        JSONObject object = null;
        String Job_id="";

        try {
            JSONObject object1=json.getJSONObject("data");
            if(object1.has("key0")){

                Job_id=object1.getString("key0");

                Job_status_message=object1.getString("title");
                System.out.println("------------Job_Message--------"+ Job_status_message);
                if (Job_status_message.equalsIgnoreCase("You got a request for a new job") || Job_status_message.equalsIgnoreCase("Payment Completed")
                        || Job_status_message.equalsIgnoreCase("User Cancelled this job"))
                {
                    job_id=object1.getString("key0");
                }
                else{
                    message=object1.getString("key0");
                }
            }
            else{
                object=json.getJSONObject("data");
                JSONArray array=object.getJSONArray("messages");
                JSONObject data = array.getJSONObject(0);

                 title = getResources().getString(R.string.Chat_Notification);
                 message = data.getString("message");
                 if(data.has("image")){
                    imageUrl = data.getString("image");
                }
                 timestamp = data.getString("date");
                 tasker_id=object.getString("tasker");
                 task_id=object.getString("task");
                 user_id=object.getString("user");

                Log.e(TAG, "title: " + title);
                Log.e(TAG, "message: " + message);
                Log.e(TAG, "tasker_id: " + tasker_id);
                Log.e(TAG, "task_id: " + task_id);
            }

                // app is in background, show the notification in notification tray
                if (Job_status_message.equalsIgnoreCase("You got a request for a new job"))
                {
                    resultIntent = new Intent(getApplicationContext(), MyJobs_OnGoingDetailPage.class);
                    resultIntent.putExtra("JobId", job_id);
                    resultIntent.putExtra("status", "ongoing");
                    title = getResources().getString(R.string.Job_Notification);
                    message=Job_status_message;
                }

                else if(Job_status_message.equalsIgnoreCase("Payment Completed")){
                    resultIntent = new Intent(getApplicationContext(), ReviwesPage.class);
                    resultIntent.putExtra("jobId", job_id);
                    title = getResources().getString(R.string.Payment_Completed);
                    message=Job_status_message;

                }
                else if (Job_status_message.equalsIgnoreCase("User Cancelled this job")) {
                    title = getResources().getString(R.string.Job_Cancelled_Notification);
                    message=Job_status_message;
                    resultIntent = new Intent(getApplicationContext(), MyJobs.class);
                    resultIntent.putExtra("status","cancelled");
                } else if (Job_status_message.equalsIgnoreCase("Please Accept the Pending task")) {
                    title = getResources().getString(R.string.Please_Accept_the_Pending_task)+" "+Job_id+")";
                    message = Job_status_message;
                    resultIntent = new Intent(getApplicationContext(), NewLeadsPage.class);
                }
                else if(Job_status_message.equalsIgnoreCase("Your Job has been Expired"))
                {
                    title=getResources().getString(R.string.Your_Job_has_been_Expired)+" "+Job_id+")";
                    message = Job_status_message;
                    resultIntent = new Intent(getApplicationContext(), NavigationDrawer.class);
                } else if(object != null){
                    if(object.has("user")) {
                        resultIntent = new Intent(getApplicationContext(), ChatPage.class);
                        resultIntent.putExtra("TaskId", task_id);
                        resultIntent.putExtra("TaskerId", user_id);
                    }

                } else{
                    title = getResources().getString(R.string.Admin_Notification);
                    message=message+"\n"+Job_status_message;
                    resultIntent = new Intent(getApplicationContext(), NavigationDrawer.class);
                }
                // check for image attachment
                if (TextUtils.isEmpty(imageUrl)) {
                    showNotificationMessage(getApplicationContext(), title, message, timestamp, resultIntent);
                } else {
                    // image is present, show notification with image
                    showNotificationMessageWithBigImage(getApplicationContext(), title, message, timestamp, resultIntent, imageUrl);
                }

        } catch (JSONException e) {
            Log.e(TAG, "Json Exception: " + e.getMessage());
        } catch (Exception e) {
            Log.e(TAG, "Exception: " + e.getMessage());
        }
    }

    /**
     * Showing notification with text only
     */
    private void showNotificationMessage(Context context, String title, String message, String timeStamp, Intent intent) {
        notificationUtils = new NotificationUtils(context);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        notificationUtils.showNotificationMessage(title, message, timeStamp, intent);
    }

    /**
     * Showing notification with text and image
     */
    private void showNotificationMessageWithBigImage(Context context, String title, String message, String timeStamp, Intent intent, String imageUrl) {
        notificationUtils = new NotificationUtils(context);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        notificationUtils.showNotificationMessage(title, message, timeStamp, intent, imageUrl);
    }
}