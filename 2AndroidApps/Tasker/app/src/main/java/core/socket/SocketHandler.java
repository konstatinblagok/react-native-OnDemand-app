package core.socket;

import android.content.Context;
import android.os.Messenger;

import com.a2zkaj.Utils.SessionManager;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

/**
 */
public class SocketHandler {
    private Context context;
    private SocketManager manager;
    private SocketParser parser;
    private SessionManager sessionManager;
    public static SocketHandler instance;
    private String status="";
    private ArrayList<Messenger> listenerMessenger;

    private SocketHandler(Context context) {
        this.context = context;
        this.manager = new SocketManager(context,callBack);
        this.sessionManager = new SessionManager(context);
        this.parser = new SocketParser(context, sessionManager);
        this.listenerMessenger = new ArrayList<Messenger>();
    }

    public static SocketHandler getInstance(Context context) {
        if (instance == null) {
            instance = new SocketHandler(context);
        }
        return instance;
    }

    public void addChatListener(Messenger messenger) {
        listenerMessenger.add(messenger);
    }

    public SocketManager getSocketManager() {
        HashMap<String, String> user = sessionManager.getUserDetails();
        String provider_id = user.get(SessionManager.KEY_PROVIDERID);
        System.out.println("handler provider_id-------------"+provider_id);
        manager.setTaskId(provider_id);


        return manager;
    }

    public SocketManager.SocketCallBack callBack = new SocketManager.SocketCallBack() {
        boolean isChat = false;

        @Override
        public void onSuccessListener(Object response) {
            if (response instanceof JSONObject) {
                JSONObject jsonObject = (JSONObject) response;

                System.out.println("socktresponse--------"+jsonObject);


                try {

                    String username = jsonObject.getString("username");
                    String message = jsonObject.getString("message");
                    android.os.Message chatMessage = android.os.Message.obtain();
                    chatMessage.obj = jsonObject.toString();
                    isChat = true;
                    for (Messenger m :
                            listenerMessenger) {
                        if (m != null)
                            m.send(chatMessage);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    isChat = false;
                }
                if (isChat) {
                    parser.parseJSON(jsonObject);
                }
                if(jsonObject.has("status")){
                    parser.parseJSON(jsonObject);
                }

            }
        }
    };
}
