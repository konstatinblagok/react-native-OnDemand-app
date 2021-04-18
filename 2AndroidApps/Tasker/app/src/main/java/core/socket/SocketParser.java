package core.socket;

import android.content.Context;
import android.content.Intent;
import android.media.MediaPlayer;
import android.provider.Settings;

import com.a2zkaj.Utils.SessionManager;

import org.json.JSONException;
import org.json.JSONObject;

import core.Xmpp.Xmpp_PushNotificationPage;
import core.service.ServiceConstant;

public class SocketParser implements ServiceConstant {
    private SessionManager sessionManager;
    private Context context;
    private MediaPlayer mediaPlayer;
    private String status="";
    public SocketParser(Context context, SessionManager sessionManager) {
        this.context = context;
        this.sessionManager = sessionManager;
        mediaPlayer = MediaPlayer.create(context, Settings.System.DEFAULT_NOTIFICATION_URI);
    }

    public String getStringJSON(JSONObject object, String name) {
        try {
            return object.getString(name);
        } catch (Exception e) {
        }
        return "";
    }

    public void parseJSON(JSONObject object) {

        if (mediaPlayer != null) {
            if (!mediaPlayer.isPlaying()) {
                mediaPlayer.start();
            }
        }

        if(object.has("status")){
            try {
                status=object.getString("status");
                 if (status.equalsIgnoreCase("0") || status.equalsIgnoreCase("1")) {
                    AvailabilityChange(status);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }else{
            try {


                JSONObject jobject = object.getJSONObject("message");

                String action = jobject.getString(ACTION_TAG);
                String message = jobject.getString(MESSAGE_TAG);
                String key1 = jobject.getString(KEY1_TAG);

                System.out.println("jobject-----------------" + jobject);
                System.out.println("socketdata-----------------" + object);
                System.out.println("action---------" + action);
                System.out.println("message-------------" + message);
                System.out.println("key1------------------" + key1);
                System.out.println("data-------------" + object);

                if (ServiceConstant.ACTION_TAG_JOB_REQUEST.equalsIgnoreCase(action)) {
                    jobRequest(jobject);
                } else if (ServiceConstant.ACTION_TAG_JOB_CANCELLED.equalsIgnoreCase(action)) {
                    jobCancelled(jobject);
                } else if (ServiceConstant.ACTION_TAG_JOB_ASSIGNED.equalsIgnoreCase(action)) {
                    jobAssigned(jobject);
                } else if (ServiceConstant.ACTION_TAG_RECEIVE_CASH.equalsIgnoreCase(action)) {
                    System.out.println("recwivecash1-------");
                    receiveCash(jobject);
                } else if (ServiceConstant.ACTION_TAG_PAYMENT_PAID.equalsIgnoreCase(action)) {
                    paymentPaid(jobject);
                } else if (ServiceConstant.ACTION_REJECT_TASK.equalsIgnoreCase(action)) {
                    JobRejected(jobject);
                }
                else if (ServiceConstant.Admin_Notification.equalsIgnoreCase(action)) {
                    JobRejected(jobject);
                }
                else if (ServiceConstant.ACTION_TAG_PARTIALLY_PAID.equalsIgnoreCase(action)) {
                    PartiallyPaid(jobject);
                }
                else if(ServiceConstant.ACTION_LEFT_JOB.equalsIgnoreCase(action)) {
                    JobPending(jobject);
                } else if (ServiceConstant.ACTION_PENDING_TASK.equalsIgnoreCase(action)) {
                    JobPending(jobject);
                }


            } catch (Exception e) {
                e.printStackTrace();
            }


        }



    }

    private void jobRequest(JSONObject messageObject) throws Exception {

//        Intent intent = new Intent(context, MyJobs_OnGoingDetailPage.class);
//
//        intent.putExtra("JobId", getStringJSON(messageObject,"key1"));
//        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//        context.startActivity(intent);


        System.out.println("job request given-------");
        notificationfinish();
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", getStringJSON(messageObject, "message"));
        intent.putExtra("Action", getStringJSON(messageObject, "action"));
        intent.putExtra("JobId", getStringJSON(messageObject, "key0"));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    private void jobAssigned(JSONObject messageObject) throws Exception {
    }

    private void jobCancelled(JSONObject messageObject) throws Exception {
        notificationfinish();
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", getStringJSON(messageObject, "message"));
        intent.putExtra("Action", getStringJSON(messageObject, "action"));
        intent.putExtra("JobId", getStringJSON(messageObject, "key1"));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    private void receiveCash(JSONObject messageObject) throws Exception {
        System.out.println("recivecash2-------");
        notificationfinish();
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", getStringJSON(messageObject, "message"));
        intent.putExtra("Action", getStringJSON(messageObject, "action"));
        intent.putExtra("amount", getStringJSON(messageObject, "key3"));
        intent.putExtra("JobId", getStringJSON(messageObject, "key1"));
        intent.putExtra("Currencycode", getStringJSON(messageObject, "key4"));
        System.out.println("recwivecash3-------");
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);

    }


    private void paymentPaid(JSONObject messageObject) throws Exception {
        notificationfinish();

        Intent broadcastIntentnavigation = new Intent();
        broadcastIntentnavigation.setAction("com.package.finish_LOADINGPAGE");
        context.sendBroadcast(broadcastIntentnavigation);

        Intent broadcastnewleads = new Intent();
        broadcastnewleads.setAction("com.finish.NewLeadsFragmet");
        context.sendBroadcast(broadcastnewleads);


        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", getStringJSON(messageObject, "message"));
        intent.putExtra("Action", getStringJSON(messageObject, "action"));
        intent.putExtra("JobId", getStringJSON(messageObject, "key0"));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);

    }


    private void notificationfinish() {
        Intent broadcastIntentnavigation = new Intent();
        broadcastIntentnavigation.setAction("com.package.finish_PUSHNOTIFIACTION");
        context.sendBroadcast(broadcastIntentnavigation);

    }

    private void JobRejected(JSONObject messageObject) throws Exception {
        notificationfinish();
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", getStringJSON(messageObject, "message"));
        intent.putExtra("Action", getStringJSON(messageObject, "action"));
        intent.putExtra("JobId", getStringJSON(messageObject, "key0"));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    private void JobPending(JSONObject messageObject) throws Exception {
        notificationfinish();
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", getStringJSON(messageObject, "message"));
        intent.putExtra("Action", getStringJSON(messageObject, "action"));
        intent.putExtra("JobId", getStringJSON(messageObject, "key0"));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    private void AvailabilityChange(String status){

        notificationfinish();
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Action", "Admin Availability Change");
       if(status.equalsIgnoreCase("0")){
           intent.putExtra("Message", "Availability Off");
       }else{
           intent.putExtra("Message", "Availability On");
       }
        intent.putExtra("JobId", status);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }



    private void PartiallyPaid(JSONObject messageObject) throws Exception {
        notificationfinish();
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", getStringJSON(messageObject, "message"));
        intent.putExtra("Action", getStringJSON(messageObject, "action"));
        intent.putExtra("JobId", getStringJSON(messageObject, "key0"));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

}
