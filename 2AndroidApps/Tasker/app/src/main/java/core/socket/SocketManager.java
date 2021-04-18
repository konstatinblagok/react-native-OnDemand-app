package core.socket;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;


import com.github.nkzawa.emitter.Emitter;
import com.github.nkzawa.socketio.client.IO;
import com.github.nkzawa.socketio.client.Socket;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;
import java.util.HashSet;

import core.service.ServiceConstant;


/**
 */
public class SocketManager {
    private Activity activity;
    private SocketCallBack callBack;
    public static final String EVENT_NEW_MESSAGE = "notification";
    private HashSet<Object> uniqueBucket;
    private boolean isAdded = false;
    public boolean isConnected;
    public static final String JOIN_NETWORK = "join network";
    public static final String NETWORK_CREATED = "network created";
    public static final String EVENT_LOCATION = "tasker tracking";

    public static final String EVENT_AVAILABILITY="availability status";

    private String provider_id = "";
    private Context context;

    public static String sProviderID = "";

    public static interface SocketCallBack {
        void onSuccessListener(Object response);
    }

    public SocketManager(Activity activity, SocketCallBack callBack) {
        this.activity = activity;
        this.callBack = callBack;
        this.uniqueBucket = new HashSet<Object>();
        System.out.println("provider_idsession-----------" + provider_id);
    }

    public SocketManager(Context activity, SocketCallBack callBack) {
        this.callBack = callBack;
        this.context = activity;
    }


    public void setTaskId(String providerID) {
        sProviderID = providerID;
        Log.d("SOCKET MANAGER", "providerID " + providerID);
    }

    private Socket mSocket;

    {
        try {
            mSocket = IO.socket(ServiceConstant.SOCKET_HOST_URL);
            mSocket.io().reconnection(true);

        } catch (URISyntaxException e) {
        }
    }


    public void connect() {
        try {
            Log.d("SOCKET MANAGER", "Connecting.... ");
            mSocket.on(Socket.EVENT_CONNECT, onConnectMessage);
            mSocket.on(Socket.EVENT_DISCONNECT, onDisconnectMessage);
            mSocket.connect();
        }
        catch (Exception e) {
        }
    }


    private Emitter.Listener onupdatelocation = new Emitter.Listener() {
        @Override
        public void call(Object... args) {
            Log.d("SOCKET MANAGER", "UPDATE LOCATION");

        }
    };



    private Emitter.Listener onNetworkJoinListener = new Emitter.Listener() {

        @Override
        public void call(Object... args) {
            Log.d("SOCKET MANAGER", "Joined To Network");

        }
    };


    private Emitter.Listener onConnectMessage = new Emitter.Listener() {
        @Override
        public void call(Object... args) {
            Log.d("SOCKET MANAGER", "Connected");
            mSocket.off(EVENT_NEW_MESSAGE, onNewMessage);
            mSocket.off(NETWORK_CREATED, onNetworkJoinListener);
            mSocket.off(EVENT_LOCATION, onupdatelocation);
            mSocket.off(EVENT_AVAILABILITY, onavailalbilityupdate);

            mSocket.on(EVENT_NEW_MESSAGE, onNewMessage);
            mSocket.on(NETWORK_CREATED, onNetworkJoinListener);
            mSocket.on(EVENT_LOCATION, onupdatelocation);
            mSocket.on(EVENT_AVAILABILITY, onavailalbilityupdate);

           // Toast.makeText(context.getApplicationContext(),"Socket Manager is connected",Toast.LENGTH_SHORT).show();

            JSONObject object = new JSONObject();
            System.out.println("socket connect----------");
            System.out.println("provider_id socket--------------" + sProviderID);
            if (sProviderID != null && sProviderID.length() > 0) {
                try {
                    object.put("user", sProviderID);
                    createRoom(object);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
            isConnected = true;
        }
    };


    private Emitter.Listener onDisconnectMessage = new Emitter.Listener() {
        @Override
        public void call(Object... args) {
            Log.d("SOCKET MANAGER", "DISCONNECTED");

           // Toast.makeText(context.getApplicationContext(),"Socket Manager is DISCONNECTED",Toast.LENGTH_SHORT).show();

            isConnected = false;
        }
    };


    public void disconnect() {
        try {
            mSocket.off(EVENT_NEW_MESSAGE, onNewMessage);
            mSocket.disconnect();
        } catch (Exception e) {
        }
    }

    public void sendMessage(String message) {
        if (TextUtils.isEmpty(message)) {
            return;
        }
        mSocket.emit(EVENT_NEW_MESSAGE, message);
    }


    public void sendlocation(Object msg) {
        if (TextUtils.isEmpty(msg.toString())) {
            return;
        }
        mSocket.emit(EVENT_LOCATION, msg);
    }

    private Emitter.Listener onNewMessage = new Emitter.Listener() {
        @Override
        public void call(final Object... args) {
            Log.d("SOCKET MANAGER", "onNewMessage " + args[0]);

            if (activity != null) {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (callBack != null) {
                            callBack.onSuccessListener(args[0]);
                        }
                    }
                });
            } else {
                if (callBack != null) {
                    callBack.onSuccessListener(args[0]);
                }
            }
        }
    };

    private Emitter.Listener onavailalbilityupdate = new Emitter.Listener() {
        @Override
        public void call(final Object... args) {
            Log.d("SOCKET MANAGER", "onAvailability_Updated " + args[0]);

            if (activity != null) {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (callBack != null) {
                            callBack.onSuccessListener(args[0]);
                        }
                    }
                });
            } else {
                if (callBack != null) {
                    callBack.onSuccessListener(args[0]);
                }
            }
        }
    };

    public void createRoom(Object userID) {
        Log.d("SOCKET MANAGER", "Joining ROOM..");
       // Toast.makeText(context.getApplicationContext(),"Socket Manager is Joining ROOM..",Toast.LENGTH_SHORT).show();


        if (userID == null) {
            return;
        }
        mSocket.emit(JOIN_NETWORK, userID);
    }


}
