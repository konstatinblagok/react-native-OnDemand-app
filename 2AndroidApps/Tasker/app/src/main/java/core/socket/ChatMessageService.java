package core.socket;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.a2zkaj.Pojo.ReceiveMessageEvent;
import com.a2zkaj.Pojo.SendMessageEvent;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.ChatPage;
import com.a2zkaj.app.R;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * Created by user145 on 4/7/2017.
 */
public class ChatMessageService extends Service {

    static ChatMessageSocketManager manager;
    static public ChatMessageService service;
    private ActiveSocketDispatcher dispatcher;
    public static Context context;
    public static String task_id = "";
    public static String tasker_id = "";
    public static String user_id = "";
    private String mCurrentUserId;
    //  private MessageDBHelper messageDB;

    public static final long MIN_GET_OFFLINE_MESSAGES_TIME = 60 * 1000; // 60 seconds

    public static boolean isStarted() {
        if (service == null)
            return false;
        return true;
    }


    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(SendMessageEvent event) {
        manager.send(event.getMessageObject(), event.getEventName());
    }

    @Override
    public void onCreate() {
        super.onCreate();

        EventBus.getDefault().register(this);

        manager = new ChatMessageSocketManager(this, callBack);
        service = this;
        context = this;
        dispatcher = new ActiveSocketDispatcher();
        SessionManager session = new SessionManager(ChatMessageService.this);
        HashMap<String, String> userDetails = session.getUserDetails();
        mCurrentUserId = userDetails.get(session.KEY_PROVIDERID);

        manager.connect();
    }

    public static void checkSocketConnected() {
        if (!manager.isConnected()) {
        }
    }

    ChatMessageSocketManager.SocketCallBack callBack = new ChatMessageSocketManager.SocketCallBack() {
        @Override
        public void onSuccessListener(String eventName, Object... response) {
            ReceiveMessageEvent me = new ReceiveMessageEvent();
            me.setEventName(eventName);
            me.setObjectsArray(response);

            switch (eventName) {

                case ChatMessageSocketManager.EVENT_CONNECT:
                    if (!manager.isConnected()) {
                        manager.connect();
                    }
                    Log.e("CHAT MANAGER", "CHAT MANAGER RECONNECTED");
                    break;
                case ChatMessageSocketManager.EVENT_DISCONNECT:
                    manager.connect();
                    break;

                case ChatMessageSocketManager.EVENT_UPDATE_CHAT:
                    PushNotification(response[0].toString());
                    break;

                case ChatMessageSocketManager.EVENT_TYPING:
                    break;

                case ChatMessageSocketManager.EVENT_STOP_TYPING:
                    break;

                case ChatMessageSocketManager.EVENT_SINGLE_MESSAGE_STATUS:
                    break;


            }

            dispatcher.addwork(me);
        }
    };

    public class ActiveSocketDispatcher {
        private BlockingQueue<Runnable> dispatchQueue
                = new LinkedBlockingQueue<Runnable>();

        public ActiveSocketDispatcher() {
            Thread mThread = new Thread(new Runnable() {
                @Override
                public void run() {
                    while (true) {
                        try {
                            dispatchQueue.take().run();
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }
                }
            });
            mThread.start();
        }

        private void addwork(final Object packet) {
            try {
                dispatchQueue.put(new Runnable() {
                    @Override
                    public void run() {
                        EventBus.getDefault().post(packet);
                    }
                });
            } catch (Exception e) {
            }
        }
    }

    public void PushNotification(String msgData) {
        SessionManager session = new SessionManager(ChatMessageService.this);
        HashMap<String, String> chatid = session.getUserDetails();
        String Chat_User_Id = chatid.get(SessionManager.KEY_Chat_userid);
        HashMap<String, String> taskids = session.getUserDetails();
        String Chat_task_id = taskids.get(SessionManager.KEY_Task_id);
        String msg_id = "";
        String confirm_msg_id = "";
        String message_from = "";
        JSONObject object = null;
        try {
            object = new JSONObject(msgData);
            user_id = object.getString("user");
            task_id = object.getString("task");
            tasker_id = object.getString("tasker");
            JSONArray array = object.getJSONArray("messages");
            JSONObject msg_object = array.getJSONObject(0);
            String message = msg_object.getString("message");
            msg_id = msg_object.getString("_id");
            message_from = msg_object.getString("from");
            if (!msg_id.equalsIgnoreCase(confirm_msg_id)) {
                confirm_msg_id = msg_id;
                message = msg_object.getString("message");
            }

            NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            PendingIntent contentIntent = null;
            Intent intent = new Intent(context, ChatPage.class);
            intent.putExtra("TaskId", task_id);
            intent.putExtra("TaskerId", user_id);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK |
                    Intent.FLAG_ACTIVITY_SINGLE_TOP);
            contentIntent = PendingIntent.getActivity(context, 0, intent
                    , 0);
            Resources res = ChatMessageService.this.getResources();
            NotificationCompat.Builder mBuilder =
                    new NotificationCompat.Builder(context)
                            .setSmallIcon(R.mipmap.handylogo)
                            .setLargeIcon(BitmapFactory.decodeResource(res, R.mipmap.handylogo)).setTicker(msgData)
                            .setContentTitle(getResources().getString(R.string.chat_message_service_chat_user))
                            .setStyle(new NotificationCompat.BigTextStyle()
                                    .bigText(message))
                            .setContentText(message).setAutoCancel(true)
                            .setSound(Uri.parse("android.resource://com.maidacpartner/" + R.raw.notifysnd));
            if (!mCurrentUserId.equalsIgnoreCase(message_from)) {
                if (!ChatPage.isChatPageAvailable || !Chat_User_Id.equalsIgnoreCase(user_id) || !Chat_task_id.equalsIgnoreCase(task_id)) {

                    mBuilder.setPriority(Notification.PRIORITY_HIGH);
                    mBuilder.setVibrate(new long[]{1000, 1000, 1000, 1000, 1000});
                    mBuilder.setContentIntent(contentIntent);
                    mNotificationManager.notify(1, mBuilder.build());

                    if (ChatPage.isChatPageAvailable) {
                        ChatPage.chat_activity.finish();
                    }


                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }


    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Toast.makeText(this, "SERVICE IS START_STICKY " + intent, Toast.LENGTH_LONG).show();
        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }


    @Override
    public void onDestroy() {
        EventBus.getDefault().unregister(this);
        service = null;
        manager.disconnect();
        //Toast.makeText(this, "SERVICE IS DESROYERD ", Toast.LENGTH_LONG).show();
        super.onDestroy();
    }

}
