package core.Xmpp;


import android.app.IntentService;
import android.content.Context;
import android.content.Intent;

import org.json.JSONObject;

/**
 * Created by user88 on 1/11/2016.
 * TODO: NEED TO REMOVE THE CLASS
 */

public class ChatHandler {

    private Context context;
    private IntentService service;

    public ChatHandler(Context context, IntentService service) {
        this.context = context;
        this.service = service;
    }


    private void jobRequest(JSONObject messageObject) throws Exception {

        System.out.println("jobrequest-------");
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        System.out.println("jobrequest1-------");
        intent.putExtra("Message", messageObject.getString("message"));
        intent.putExtra("Action", messageObject.getString("action"));
        intent.putExtra("JobId", messageObject.getString("key1"));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        System.out.println("jobrequest2-------");

        service.startActivity(intent);
        System.out.println("jobrequest3-------");

    }

    private void jobAssigned(JSONObject messageObject) throws Exception {


    }


    private void jobCancelled(JSONObject messageObject) throws Exception {

        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", messageObject.getString("message"));
        intent.putExtra("Action", messageObject.getString("action"));
        intent.putExtra("JobId", messageObject.getString("key1"));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        service.startActivity(intent);


    }

    private void receiveCash(JSONObject messageObject) throws Exception {
        System.out.println("recwivecash2-------");
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", messageObject.getString("message"));
        intent.putExtra("Action", messageObject.getString("action"));
        intent.putExtra("amount", messageObject.getString("key3"));
        intent.putExtra("JobId", messageObject.getString("key1"));
        intent.putExtra("Currencycode", messageObject.getString("key4"));

        System.out.println("recwivecash3-------");
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        service.startActivity(intent);

    }


    private void paymentPaid(JSONObject messageObject) throws Exception {
        Intent intent = new Intent(context, Xmpp_PushNotificationPage.class);
        intent.putExtra("Message", messageObject.getString("message"));
        intent.putExtra("Action", messageObject.getString("action"));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        service.startActivity(intent);

    }


}
